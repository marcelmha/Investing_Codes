#install.packages(c("yfR", "dplyr", "TTR", "purrr", "tidyr", "readr"))
# ANÁLISE TÉCNICA EM LOTE - B3 (Versão Corrigida) ================================
library(yfR)
library(dplyr)
library(TTR)
library(purrr)
library(tidyr)
library(readr)

# Configurações ------------------------------------------------------------------
caminho_tickers <- "./tickers.txt"
diretorio_relatorios <- "./Relatorios"

# Criar diretório se não existir
if(!dir.exists(diretorio_relatorios)) {
  dir.create(diretorio_relatorios, recursive = TRUE)
}

# Ler e processar tickers (corrigindo aviso de linha incompleta)
tickers_b3 <- readLines(caminho_tickers, warn = FALSE) %>% 
  trimws() %>% 
  .[nzchar(.)] %>%          
  paste0(".SA")

start_date <- Sys.Date() - 730
end_date <- Sys.Date()

# Função de Análise Técnica Corrigida --------------------------------------------
analisar_acao <- function(ticker) {
  tryCatch({
    dados <- yf_get(ticker, first_date = start_date, last_date = end_date)
    
    # Verificação robusta de dados
    if(nrow(dados) < 300 || sum(is.na(dados$price_close)) > 50) {
      message(paste("Dados insuficientes para", ticker))
      return(NULL)
    }
    
    dados <- dados %>%
      mutate(
        SMA_9 = SMA(price_close, 9),
        SMA_21 = SMA(price_close, 21),
        RSI = RSI(price_close, 14),
        MACD_obj = MACD(price_close, 12, 26, 9),
        MACD_line = MACD_obj[, "macd"],
        MACD_signal = MACD_obj[, "signal"],
        Volume_Media = SMA(volume, 20),
        
        # Cálculos de retorno
        Retorno_5D = (price_close/dplyr::lag(price_close, 5) - 1) * 100,
        Retorno_20D = (price_close/dplyr::lag(price_close, 20) - 1) * 100,
        
        # Fibonacci
        Max_21 = runMax(price_high, 21),
        Min_21 = runMin(price_low, 21),
        Fib_382 = (Max_21 - Min_21) * 0.382 + Min_21,
        Fib_618 = (Max_21 - Min_21) * 0.618 + Min_21
      ) %>%
      filter(!is.na(SMA_21)) %>%
      tail(1)
    
    if(nrow(dados) == 0) return(NULL)
    
    # Cálculo do Score revisado (CORREÇÃO CRÍTICA)
    score_components <- c(
      macd = ifelse(dados$MACD_line > dados$MACD_signal, 2, 0),
      rsi = ifelse(between(dados$RSI, 45, 65), 1, 0),
      tendencia = ifelse(dados$SMA_9 > dados$SMA_21, 2, 0),
      volume = ifelse(dados$volume > dados$Volume_Media, 1, 0),
      preco = ifelse(dados$price_close > dados$SMA_21, 1, 0)
    )
    
    score_total <- sum(score_components, na.rm = TRUE) * (10/7)
    
    # CORREÇÃO: Parênteses corretos e clamping 0-10
    score_final <- pmin(pmax(round(score_total, 1), 0), 10)  # <--- Aqui estava o erro!
    
    # Classificação realista
    recomendacao <- case_when(
      score_final >= 8 ~ "COMPRA FORTE",
      score_final >= 6.5 ~ "COMPRA",
      score_final >= 5 ~ "NEUTRO",
      TRUE ~ "VENDA"
    )
    
    tibble(
      Ticker = gsub("\\.SA$", "", ticker),
      Valor_Atual = round(dados$price_close, 2),
      Score = score_final,
      Recomendacao = recomendacao,
      MACD = ifelse(score_components["macd"] > 0, "Positivo", "Negativo"),
      RSI = round(dados$RSI, 1),
      Tendencia = paste0(round((dados$SMA_9/dados$SMA_21 - 1) * 100, 2), "%"),
      Volume = ifelse(score_components["volume"] > 0, "Acima", "Abaixo"),
      Stop_Gain_1 = round(dados$Fib_382, 2),
      Stop_Gain_2 = round(dados$Fib_618, 2),
      Variacao_5D = paste0(round(dados$Retorno_5D, 2), "%")
    )
    
  }, error = function(e) {
    message(paste("Erro em", ticker, ":", e$message))
    return(NULL)
  })
}

# Processamento e verificação ---------------------------------------------------
resultados <- tickers_b3 %>%
  map_dfr(~{
    message("Processando: ", .x)
    analisar_acao(.x)
  }) %>%
  filter(!is.na(Score)) %>%
  arrange(desc(Score))

# Exportar CSV -------------------------------------------------------------------
if(nrow(resultados) > 0) {
  nome_arquivo <- paste0(
    "Relatorio_Acoes_",
    format(Sys.time(), "%d-%m-%Y_%H-%M-%S"), 
    ".csv"
  )
  caminho_completo <- file.path(diretorio_relatorios, nome_arquivo)
  write_csv(resultados, caminho_completo)
  cat("\n✅ Relatório gerado com sucesso!\nCaminho:", caminho_completo)
} else {
  cat("\n❌ Nenhum dado válido processado. Verifique:")
  cat("\n   1. Arquivo de tickers")
  cat("\n   2. Conexão com internet")
  cat("\n   3. Datas históricas")
}
