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
````
2. Instale as dependências::
```bash
pip install -r requirements.txt
```
(Arquivo requirements.txt sugerido:)
```bash
yfinance==0.2.28
tabulate==0.9.0
pandas==2.0.3
```
## ⚙️ Configuração

Estrutura de Arquivos
```bash
D:\Temp\Config
├── tickers.txt         # Lista de ativos
├── destinatarios.txt   # Lista de e-mails
├── servicemail.txt     # E-mail remetente
├── app.txt             # Nome do serviço
└── pw.txt              # Senha de aplicativo
```
1. tickers.txt (um ticker por linha):
```bash
VALE3
PETR4
ITUB4
BBDC4
...
```
2. destinatarios.txt (formato: Nome, e-mail):
```bash
"João Silva", joao.silva@exemplo.com
"Maria Souza", maria.s@empresa.com.br
```
3. servicemail.txt:
```bash
servicemail.txt:
```
4. app.txt:
```bash
Seu Serviço de E-mail
```
5. pw.txt (crie senha de app):
```bash
sua-senha-de-16-digitos
```
## 🏃‍♂️ Como Executar

```bash
python analisador_acoes.py
```
**Saída Esperada** 
```bash
🔍 Iniciando análise...
Processando VALE3 (1/25)...
Processando PETR4 (2/25)...
...
✅ Relatório salvo como: Relatorio_Investimento_20231025_1430.csv
E-mail enviado para: João Silva (joao.silva@exemplo.com)
E-mail enviado para: Maria Souza (maria.s@empresa.com.br)
```
## 📊 Exemplos de Saída
**Relatório CSV**
```bash
Ticker;Preço;Recomendação;Tendência (%);Volume (%);SG (38.2%);SG (61.8%);SG (100%);SL (23.6%);SL (38.2%);SL (61.8%)
VALE3;89.15;COMPRAR ✅;2.45;150.3;92.50;95.80;98.15;87.20;85.90;83.50
PETR4;32.90;VENDER ❌;-1.78;120.7;31.50;30.20;28.90;33.80;34.50;35.90
```
**Relatório HTML**
Exemplo de Relatório HTML
```bash
                                            📈 Relatório de Oportunidades na B3
                                                Análise técnica com base em:

                                        • Tendência de preço vs média móvel de 20 períodos
                                               • Volume negociado vs média histórica
                                                 • Definição de níveis operacionais
🔔 99 Oportunidades Identificadas

Ticker	Preço (R$)	Recomendação	Tendência (%)	Volume (%)	SG (38.2%)	SG (61.8%)	SG (100%)	SL (23.6%)	SL (38.2%)	SL (61.8%)
TICK3	R$ 9.99	    COMPRAR ✅	    37.34%	        190.8%	    R$ 10.31	R$ 10.54   	R$ 10.90	R$ 9.73 	R$ 9.59 	R$ 9.36
...
...
Continua ...
```

## 🛠️ Personalização
1. Para alterar o diretório de configuração:
```python
# Linha 13 do código
CONFIG_PATH = r"SEU_NOVO_CAMINHO"  # Ex: r"C:\Config\B3_Analyzer"
```
2. Para modificar os períodos de análise:
```bash
# Na função analyze_stock(), linha 64
hist = stock.history(period="60d")  # Altere para "90d" ou outro período
```
3. Para ajustar os limiares de recomendação:
```bash
# Na função analyze_stock(), linhas 80-84
if trend.startswith("ALTA") and volumes[-1] > avg_volume * 1.2:  # Ex: 20% acima da média
    recommendation = "COMPRAR ✅"
```
```python
+ Dica: Configure uma tarefa agendada para execução diária automática!
- Importante: Mantenha os arquivos de configuração em local seguro!
```

## ⚠️ Aviso Legal
AVISO: Este projeto é estritamente educacional e não constitui aconselhamento financeiro. Os mercados de valores têm riscos inerentes e resultados passados não garantem desempenho futuro. Sempre consulte um profissional qualificado antes de investir.

## ⚠️ Copyright
Licença MIT

Copyright (c) 2025 Marcel Henrique Aguiar

É concedida permissão, gratuitamente, a qualquer pessoa que obtenha uma cópia
deste software e dos arquivos de documentação associados (o "Software"), para lidar
com o Software sem restrição, incluindo, sem limitação, os direitos
de usar, copiar, modificar, fundir, publicar, distribuir, sublicenciar e/ou vender
cópias do Software, e para permitir que as pessoas a quem o Software é
fornecido o façam, sob as seguintes condições:

O aviso de copyright acima e este aviso de permissão devem ser incluídos em todas
as cópias ou partes substanciais do Software.

O SOFTWARE É FORNECIDO "COMO ESTÁ", SEM QUALQUER TIPO DE GARANTIA, EXPRESSA OU
IMPLÍCITA, INCLUINDO MAS NÃO SE LIMITANDO A GARANTIAS DE COMERCIALIZAÇÃO,
ADEQUAÇÃO A UM PROPÓSITO ESPECÍFICO E NÃO VIOLAÇÃO. EM NENHUM CASO OS
AUTORES OU TITULARES DOS DIREITOS AUTORAIS SERÃO RESPONSÁVEIS POR QUALQUER RECLAMAÇÃO,
DANOS OU OUTRA RESPONSABILIDADE, SEJA EM UMA AÇÃO DE CONTRATO, DELITO OU OUTRA FORMA,
DECORRENTE DE, FORA DE OU EM CONEXÃO COM O SOFTWARE OU O USO OU OUTRAS NEGOCIAÇÕES NO
SOFTWARE.


