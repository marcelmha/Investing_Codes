# ANÁLISE TÉCNICA COMPLETA COM AçÕES B3 ========================================
# Pacotes necessários ------------------------------------------------------------
# install.packages(c("yfR", "ggplot2", "dplyr", "TTR", "gridExtra", "scales", "tidyquant"))
library(yfR)         # Obtenção de dados
library(ggplot2)     # Visualização gráfica
library(dplyr)       # Manipulação de dados
library(TTR)         # Indicadores técnicos
library(gridExtra)   # Layout de gráficos
library(scales)      # Formatação de eixos
library(tidyquant)   # Gráficos de candlestick

# Configurações ------------------------------------------------------------------
symbol <- "EMBR3.SA"   # Ativo analisado
start_date <- Sys.Date() - 365  # 1 ano de dados
end_date <- Sys.Date()

# 1. Obtenção de dados históricos ------------------------------------------------
dados <- yf_get(
  tickers = symbol,
  first_date = start_date,
  last_date = end_date
)

# 2. Processamento e cálculo de indicadores --------------------------------------
dados_analise <- dados %>%
  arrange(ref_date) %>%
  mutate(
    # Médias Móveis
    SMA_9 = SMA(price_close, n = 9),
    SMA_21 = SMA(price_close, n = 21),
    
    # Volume
    Volume_Color = ifelse(price_close > price_open, "Compra Forte", "Venda Forte"),
    Volume_Media_20 = SMA(volume, n = 20),
    Volume_Perc_Media = round((volume / Volume_Media_20 - 1) * 100, 1),
    
    # MACD
    MACD = MACD(price_close, nFast = 12, nSlow = 26, nSig = 9),
    MACD_line = MACD[, "macd"],
    MACD_signal = MACD[, "signal"],
    Histograma_MACD = MACD_line - MACD_signal,
    
    # RSI
    RSI = RSI(price_close, n = 14),
    
    # Análise de Candles
    Corpo = abs(price_close - price_open),
    Sombra_Superior = price_high - pmax(price_open, price_close),
    Sombra_Inferior = pmin(price_open, price_close) - price_low,
    Tipo_Candle = case_when(
      price_close > lag(price_close, 1) & 
        price_close > price_open & 
        price_open < lag(price_close, 1) ~ "Engolfo Altista",
      (price_close > price_open) & 
        (Sombra_Inferior > 2 * Corpo) ~ "Martelo",
      abs(price_close - price_open) < 0.02 * (price_high - price_low) ~ "Doji",
      price_close > price_open ~ "Alta",
      TRUE ~ "Baixa"
    )
  ) %>%
  na.omit()

# 3. Construção dos Gráficos -----------------------------------------------------

# Gráfico de Candlestick
p_candle <- ggplot(dados_analise, aes(x = ref_date)) +
  geom_ribbon(aes(ymin = SMA_9, ymax = SMA_21, fill = SMA_9 > SMA_21), alpha = 0.2) +
  geom_candlestick(aes(open = price_open, high = price_high, low = price_low, close = price_close),
                   colour_up = "#1a9850", colour_down = "#d73027",
                   fill_up = "#1a9850", fill_down = "#d73027") +
  geom_line(aes(y = SMA_9, color = "MM9 (9 dias)"), linewidth = 0.8) +
  geom_line(aes(y = SMA_21, color = "MM21 (21 dias)"), linewidth = 0.8) +
  scale_color_manual(values = c("MM9 (9 dias)" = "#4575b4", "MM21 (21 dias)" = "#fdae61")) +
  labs(title = paste("Gráfico -", symbol), x = "", y = "Preço (R$)") +
  theme_minimal()

# Gráfico de Volume
p_volume <- ggplot(dados_analise, aes(x = ref_date, y = volume/1e6, fill = Volume_Color)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("Compra Forte" = "#1a9850", "Venda Forte" = "#d73027")) +
  labs(x = "", y = "Volume (mi)") +
  theme_minimal()

# Gráfico MACD
p_macd <- ggplot(dados_analise, aes(x = ref_date)) +
  geom_bar(aes(y = Histograma_MACD, fill = Histograma_MACD > 0), stat = "identity") +
  geom_line(aes(y = MACD_line, color = "MACD"), linewidth = 0.7) +
  geom_line(aes(y = MACD_signal, color = "Sinal"), linewidth = 0.7) +
  scale_color_manual(values = c("MACD" = "#2b83ba", "Sinal" = "#d7191c")) +
  labs(x = "", y = "MACD") +
  theme_minimal()

# Gráfico RSI
p_rsi <- ggplot(dados_analise, aes(x = ref_date)) +
  geom_line(aes(y = RSI), color = "#762a83") +
  geom_hline(yintercept = c(30, 70), linetype = "dashed") +
  labs(x = "Data", y = "RSI") +
  ylim(0, 100) +
  theme_minimal()

# 4. Análise Técnica Detalhada ---------------------------------------------------
ultimo <- tail(dados_analise, 1)

# Critérios Técnicos
sinais <- list(
  MACD = ultimo$MACD_line > ultimo$MACD_signal,
  RSI = between(ultimo$RSI, 40, 70),
  Tendencia = ultimo$SMA_9 > ultimo$SMA_21,
  Volume = ultimo$volume > ultimo$Volume_Media_20,
  Candle = ultimo$Tipo_Candle %in% c("Engolfo Altista", "Martelo")
)

pontuacao <- sum(unlist(sinais))
recomendacao <- case_when(
  pontuacao >= 4 ~ "COMPRA FORTE 📈",
  pontuacao == 3 ~ "COMPRA MODERADA ⬆️",
  pontuacao == 2 ~ "NEUTRO ⏸️",
  pontuacao == 1 ~ "VENDA MODERADA ⬇️",
  TRUE ~ "VENDA FORTE 📉"
)

# 5. Exibição dos Resultados -----------------------------------------------------
# Plotar gráficos
grid.arrange(p_candle, p_volume, p_macd, p_rsi, ncol = 1)

# Análise Detalhada
cat("\n\u001b[36m============= ANÁLISE TÉCNICA AVANÇADA =============\u001b[0m\n")

indicadores <- data.frame(
  Indicador = c("MACD > Sinal", "RSI (40-70)", "MM9 > MM21", "Volume", "Padrão Candle"),
  Valor = c(
    sprintf("%.3f > %.3f", ultimo$MACD_line, ultimo$MACD_signal),
    sprintf("%.1f", ultimo$RSI),
    sprintf("%.2f > %.2f", ultimo$SMA_9, ultimo$SMA_21),
    sprintf("%.1fM (%.1f%%)", ultimo$volume/1e6, ultimo$Volume_Perc_Media),
    ultimo$Tipo_Candle
  ),
  Status = unlist(sinais),
  Ideal = c(
    "MACD acima do sinal",
    "40-70 (Zona Neutra)",
    "MM Curta > MM Longa",
    "Acima da Média 20P",
    "Padrão Reversão"
  )
)

formatar_status <- function(status) {
  ifelse(status, "\u001b[32mATENDIDO\u001b[0m", "\u001b[31mNÃO ATENDIDO\u001b[0m")
}

for(i in 1:nrow(indicadores)) {
  cat(sprintf("\n %s %-15s: %-20s | %s (%s)",
              ifelse(indicadores$Status[i], "✅", "❌"),
              indicadores$Indicador[i],
              indicadores$Valor[i],
              formatar_status(indicadores$Status[i]),
              indicadores$Ideal[i]))
}

cat("\n\n\u001b[34m[RECOMENDAÇÃO FINAL]\u001b[0m")
cat(sprintf("\n %s \u001b[35m(%d/5 critérios atendidos)\u001b[0m\n", recomendacao, pontuacao))