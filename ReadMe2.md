markdown
Copy
# 📈 Analisador Técnico de Ações B3

Script Python para análise técnica de ações listadas na B3 (Bolsa de Valores do Brasil) com geração de relatórios e envio automático por e-mail.

<img src="https://img.shields.io/badge/Python-3.8%2B-blue?logo=python" alt="Python 3.8+"> <img src="https://img.shields.io/badge/Licença-MIT-green" alt="Licença MIT">

## 🚀 Funcionalidades

- **Análise técnica automatizada** baseada em:
  - Tendência de preço vs média móvel de 20 períodos
  - Volume negociado vs média histórica
  - Níveis de Fibonacci para definição de metas (SG) e stops (SL)
- **Classificação automática** de recomendações:
  - ✅ COMPRAR (tendência de alta com volume acima da média)
  - ❌ VENDER (tendência de baixa com volume acima da média)
  - ⏸️ NEUTRO (outros casos)
- **Relatórios em múltiplos formatos**:
  - 📄 CSV estruturado para análise detalhada
  - 🎨 HTML formatado com visualização amigável
- **Envio automático por e-mail** com:
  - 📎 Anexo do relatório CSV
  - ✉️ Corpo do e-mail em HTML
- **Configuração flexível** via arquivos texto

## 📋 Pré-requisitos

- Python 3.8 ou superior
- Conta Gmail para envio de e-mails
- Conexão com internet para acesso à API do Yahoo Finance

## 🛠️ Instalação

1. Clone o repositório:
```bash
git clone [URL_DO_SEU_REPOSITORIO]
Instale as dependências:

bash
Copy
pip install -r requirements.txt
⚙️ Configuração
Estrutura de Arquivos
Copy
D:\Temp\Config
├── tickers.txt         # Lista de ativos
├── destinatarios.txt   # Lista de e-mails
├── servicemail.txt     # E-mail remetente
├── app.txt             # Nome do serviço
└── pw.txt              # Senha de aplicativo
tickers.txt (um ticker por linha):

Copy
VALE3
PETR4
ITUB4
BBDC4
destinatarios.txt (formato: Nome, e-mail):

Copy
"João Silva", joao.silva@exemplo.com
"Maria Souza", maria.s@empresa.com.br
servicemail.txt:

Copy
seuemail@gmail.com
app.txt:

Copy
Seu Serviço de E-mail
pw.txt (crie senha de app):

Copy
sua-senha-de-16-digitos
🏃‍♂️ Como Executar
bash
Copy
python analisador_acoes.py
Saída Esperada
Copy
🔍 Iniciando análise...
Processando VALE3 (1/25)...
Processando PETR4 (2/25)...
...
✅ Relatório salvo como: Relatorio_Investimento_20231025_1430.csv
E-mail enviado para: João Silva (joao.silva@exemplo.com)
E-mail enviado para: Maria Souza (maria.s@empresa.com.br)
📊 Exemplos de Saída
Relatório CSV
csv
Copy
Ticker;Preço;Recomendação;Tendência (%);Volume (%);SG (38.2%);SG (61.8%);SG (100%);SL (23.6%);SL (38.2%);SL (61.8%)
VALE3;89.15;COMPRAR ✅;2.45;150.3;92.50;95.80;98.15;87.20;85.90;83.50
PETR4;32.90;VENDER ❌;-1.78;120.7;31.50;30.20;28.90;33.80;34.50;35.90
Relatório HTML
Exemplo de Relatório HTML

⚠️ Aviso Legal
AVISO: Este projeto é estritamente educacional e não constitui aconselhamento financeiro. Os mercados de valores têm riscos inerentes e resultados passados não garantem desempenho futuro. Sempre consulte um profissional qualificado antes de investir.

📄 Licença
Distribuído sob licença MIT. Veja o arquivo LICENSE para mais detalhes.

🛠️ Personalização
Para alterar o diretório de configuração:

python
Copy
# Linha 13 do código
CONFIG_PATH = r"SEU_NOVO_CAMINHO"  # Ex: r"C:\Config\B3_Analyzer"
Para modificar os períodos de análise:

python
Copy
# Na função analyze_stock(), linha 64
hist = stock.history(period="60d")  # Altere para "90d" ou outro período
Para ajustar os limiares de recomendação:

python
Copy
# Na função analyze_stock(), linhas 80-84
if trend.startswith("ALTA") and volumes[-1] > avg_volume * 1.2:  # Ex: 20% acima da média
    recommendation = "COMPRAR ✅"
diff
Copy
+ Dica: Configure uma tarefa agendada para execução diária automática!
- Importante: Mantenha os arquivos de configuração em local seguro!
✉️ Problemas/Sugestões: Abra uma issue no repositório ou contate o mantenedor.