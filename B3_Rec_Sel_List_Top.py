import yfinance as yf
from tabulate import tabulate
from datetime import datetime, timedelta
import csv
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
import os
import sys
from io import StringIO

# ===================================================================
# 1. PRIMEIRO DEFINIMOS TODAS AS FUNÇÕES AUXILIARES
# ===================================================================

def get_b3_tickers():
    try:
        return os.environ.get('TICKERS', '').splitlines()
    except Exception as e:
        print(f"\n⚠️ Erro ao ler tickers: {str(e)}")
        exit()

def get_recipients():
    try:
        recipients = []
        destinos = os.environ.get('DESTINATARIOS', '').splitlines()
        for line in destinos:
            if ',' in line:
                name, email = line.strip().split(',', 1)
                recipients.append((name.strip('"'), email.strip()))
        return recipients
    except Exception as e:
        print(f"Erro ao ler destinatários: {str(e)}")
        exit()
        
def get_env_var(name):
    value = os.environ.get(name)
    if not value:
        print(f"Variável de ambiente {name} não encontrada")
        exit()
    return value

def analyze_stock(ticker):
    try:
        stock = yf.Ticker(ticker + ".SA")
        hist = stock.history(period="60d")
        
        if len(hist) < 30:
            return None
            
        closes = hist['Close'].values[-30:]
        volumes = hist['Volume'].values[-30:]
        
        latest_close = closes[-1]
        sma_20 = closes[-20:].mean()
        avg_volume = volumes.mean()
        
        trend = "ALTA ↗️" if latest_close > sma_20 else "BAIXA ↘️"
        trend_pct = (latest_close/sma_20 - 1)*100
        
        if avg_volume == 0:
            volume_ratio = 0.0
        else:
            volume_ratio = (volumes[-1]/avg_volume)*100
        
        recommendation = "NEUTRO ⏸️"
        if trend.startswith("ALTA") and volumes[-1] > avg_volume:
            recommendation = "COMPRAR ✅"
        elif trend.startswith("BAIXA") and volumes[-1] > avg_volume:
            recommendation = "VENDER ❌"
            
        entry = latest_close
        
        # Cálculo dos níveis de Fibonacci
        if trend.startswith("ALTA"):
            swing_low = hist['Low'].min()
            fib_range = entry - swing_low
            sg = [
                entry + fib_range * 0.382,
                entry + fib_range * 0.618,
                entry + fib_range * 1.0
            ]
            sl = [
                entry - fib_range * 0.236,
                entry - fib_range * 0.382,
                entry - fib_range * 0.618
            ]
        else:
            swing_high = hist['High'].max()
            fib_range = swing_high - entry
            sg = [
                entry - fib_range * 0.382,
                entry - fib_range * 0.618,
                entry - fib_range * 1.0
            ]
            sl = [
                entry + fib_range * 0.236,
                entry + fib_range * 0.382,
                entry + fib_range * 0.618
            ]
        
        return {
            'Ticker': ticker,
            'Preço': latest_close,
            'Recomendação': recommendation,
            'Tendência (%)': trend_pct,
            'Volume (%)': volume_ratio,
            'SG (38.2%)': sg[0],
            'SG (61.8%)': sg[1],
            'SG (100%)': sg[2],
            'SL (23.6%)': sl[0],
            'SL (38.2%)': sl[1],
            'SL (61.8%)': sl[2],
            'Data Análise': datetime.now().strftime('%d/%m/%Y %H:%M')
        }
        
    except Exception as e:
        print(f"Erro no ticker {ticker}: {str(e)}")
        return None

def save_to_csv(data, filename):
    filepath = os.path.join(OUTPUT_PATH, filename)
    headers = data[0].keys()
    with open(filepath, 'w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=headers, delimiter=';')
        writer.writeheader()
        writer.writerows(data)

def generate_html_report(data):
    """Gera o conteúdo HTML do relatório com tabela formatada"""
    report_date = datetime.now().strftime('%d/%m/%Y %H:%M')
    num_signals = len(data)
    
    html = f"""
    <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    background-color: #f4f4f4;
                    margin: 0;
                    padding: 20px;
                }}
                .container {{
                    background-color: #ffffff;
                    padding: 30px;
                    border-radius: 10px;
                    box-shadow: 0 0 15px rgba(0,0,0,0.1);
                    max-width: 1000px;
                    margin: auto;
                }}
                h1 {{
                    text-align: center;
                    color: #2c3e50;
                    margin-bottom: 30px;
                }}
                .header-text {{
                    text-align: center;
                    margin-bottom: 25px;
                    color: #34495e;
                }}
                table {{
                    width: 100%;
                    border-collapse: collapse;
                    margin: 25px 0;
                    font-size: 0.9em;
                }}
                th {{
                    background-color: #3498db;
                    color: white;
                    padding: 12px;
                    text-align: center;
                }}
                td {{
                    padding: 12px;
                    text-align: center;
                    border-bottom: 1px solid #ddd;
                }}
                tr:hover {{background-color: #f5f5f5;}}
                .recommendation-buy {{color: #27ae60; font-weight: bold;}}
                .recommendation-sell {{color: #e74c3c; font-weight: bold;}}
                .disclaimer {{
                    font-size: 0.8em;
                    color: #7f8c8d;
                    margin-top: 30px;
                    border-top: 1px solid #eee;
                    padding-top: 20px;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>📈 Relatório de Oportunidades na B3</h1>
                
                <div class="header-text">
                    <p>Análise técnica com base em:</p>
                    <ul style="list-style: none; padding: 0;">
                        <li>• Tendência de preço vs média móvel de 20 períodos</li>
                        <li>• Volume negociado vs média histórica</li>
                        <li>• Definição de níveis operacionais</li>
                    </ul>
                </div>

                <h2>🔔 {num_signals} Oportunidades Identificadas</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Ticker</th>
                            <th>Preço (R$)</th>
                            <th>Recomendação</th>
                            <th>Tendência (%)</th>
                            <th>Volume (%)</th>
                            <th>SG (38.2%)</th>
                            <th>SG (61.8%)</th>
                            <th>SG (100%)</th>
                            <th>SL (23.6%)</th>
                            <th>SL (38.2%)</th>
                            <th>SL (61.8%)</th>
                        </tr>
                    </thead>
                    <tbody>
    """

    for item in data:
        # Determinar classe da recomendação
        rec_class = ""
        if "COMPRAR" in item['Recomendação']:
            rec_class = "class='recommendation-buy'"
        elif "VENDER" in item['Recomendação']:
            rec_class = "class='recommendation-sell'"
        
        html += f"""
                        <tr>
                            <td>{item['Ticker']}</td>
                            <td>R$ {item['Preço']:.2f}</td>
                            <td {rec_class}>{item['Recomendação']}</td>
                            <td>{item['Tendência (%)']:.2f}%</td>
                            <td>{item['Volume (%)']:.1f}%</td>
                            <td>R$ {item['SG (38.2%)']:.2f}</td>
                            <td>R$ {item['SG (61.8%)']:.2f}</td>
                            <td>R$ {item['SG (100%)']:.2f}</td>
                            <td>R$ {item['SL (23.6%)']:.2f}</td>
                            <td>R$ {item['SL (38.2%)']:.2f}</td>
                            <td>R$ {item['SL (61.8%)']:.2f}</td>
                        </tr>
        """

    html += f"""
                    </tbody>
                </table>
                
                <div class="disclaimer">
                    <p>📅 Dados atualizados em: {report_date}</p>
                    <p>⚠️ Este relatório é gerado automaticamente e não constitui recomendação de investimento. 
                    Consulte um profissional qualificado antes de tomar qualquer decisão financeira.</p>
                    <p>ℹ️ SG = Sugestão de Ganho | SL = Stop Loss</p>
                </div>
            </div>
        </body>
    </html>
    """
    return html

def send_email(csv_filename, html_content):
    sender_email = get_env_var('SERVICEMAIL')
    app_name = get_env_var('APP_NAME')
    app_password = get_env_var('APP_PASSWORD')
    recipients = get_recipients()

    with open(csv_filename, "rb") as f:
        csv_data = f.read()

    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(sender_email, app_password)
        
        for name, email in recipients:
            msg = MIMEMultipart()
            msg['From'] = f'{app_name} <{sender_email}>'
            msg['To'] = f'{name} <{email}>'
            msg['Subject'] = "Relatório com as Principais Oportunidades da B3"
            
            # Corpo do email em HTML
            msg.attach(MIMEText(html_content, 'html', 'utf-8'))
            
            # Anexo CSV
            attach = MIMEApplication(csv_data, _subtype="csv")
            attach.add_header('Content-Disposition', 'attachment', 
                            filename=os.path.basename(csv_filename))
            msg.attach(attach)
            
            server.sendmail(sender_email, email, msg.as_string())
            print(f"E-mail enviado para: {name} ({email})")
        
        server.quit()
    except Exception as e:
        print(f"Erro ao enviar e-mail: {str(e)}")
        exit()

# ===================================================================
# 2. DEPOIS DEFINIMOS A FUNÇÃO PRINCIPAL
# ===================================================================
def main():
    original_stdout = sys.stdout
    sys.stdout = buffer = StringIO()

    try:
        print("\n🔍 Iniciando análise...")
        tickers = get_b3_tickers()
        
        resultados = []
        for idx, ticker in enumerate(tickers, 1):
            print(f"Processando {ticker} ({idx}/{len(tickers)})...")
            if analise := analyze_stock(ticker):
                resultados.append(analise)
        
        resultados_ordenados = sorted(
            [r for r in resultados if r['Recomendação'] != "NEUTRO ⏸️"],
            key=lambda x: (
                0 if 'COMPRAR' in x['Recomendação'] else 1,
                -x['Tendência (%)'],
                -x['Volume (%)']
            )
        )
        
        csv_filename = f"Relatorio_Investimento_{datetime.now().strftime('%Y%m%d_%H%M')}.csv"
        if resultados_ordenados:
            save_to_csv(resultados_ordenados, csv_filename)
            print(f"\n✅ Relatório salvo como: {csv_filename}")
            
            # Gerar conteúdo HTML
            html_content = generate_html_report(resultados_ordenados)
        else:
            print("\n⚠️ Nenhum sinal relevante encontrado")
            exit()
        
        # Console output apenas para verificação
        headers = ["Ticker", "Preço", "Recomendação", "Tendência (%)", "Volume (%)", 
          "SG (38.2%)", "SG (61.8%)", "SG (100%)", "SL (23.6%)", "SL (38.2%)", "SL (61.8%)"]
        
        print("\n" + "="*120)
        print(f"📊 RELATÓRIO CONSOLIDADO - {len(resultados_ordenados)} sinal(ais)")
        print("="*120)
        
        display_data = []
        for item in resultados_ordenados:
            display_item = {
                'Ticker': item['Ticker'],
                'Preço': f"R${item['Preço']:.2f}",
                'Recomendação': item['Recomendação'],
                'Tendência (%)': f"{item['Tendência (%)']:.2f}%",
                'Volume (%)': f"{item['Volume (%)']:.1f}%",
                'SG (38.2%)': f"R${item['SG (38.2%)']:.2f}",
                'SG (61.8%)': f"R${item['SG (61.8%)']:.2f}",
                'SG (100%)': f"R${item['SG (100%)']:.2f}",
                'SL (23.6%)': f"R${item['SL (23.6%)']:.2f}",
                'SL (38.2%)': f"R${item['SL (38.2%)']:.2f}",
                'SL (61.8%)': f"R${item['SL (61.8%)']:.2f}"
            }
            display_data.append(display_item)
        
        print(tabulate(
            [list(item.values()) for item in display_data],
            headers=headers,
            tablefmt="fancy_grid",
            numalign="right",
            stralign="center"
        ))
        print("="*120)
        
    finally:
        sys.stdout = original_stdout
    
    # Enviar e-mail com HTML gerado
    send_email(csv_filename, html_content)

# ===================================================================
# 3. EXECUÇÃO DO CÓDIGO
# ===================================================================
if __name__ == "__main__":
    main()
