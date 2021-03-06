library(ggplot2)
gdp = smoots::gdpUS$GDP

lgdp <- log(gdp)
n = length(lgdp)
year = (1:n)/n * 72 + 1947
result = semifarima_pq.lpf(lgdp, p.min = 1, p.max = 1, q.min = 1, q.max = 1, pg = 1, IF = 2, kn = 2, bb = 1)
result.der1 = semifarima.der(result, lgdp, nu = 1, mse.RANGE = 0.05, kn = 2, bb = 1)
result.der2 = semifarima.der(result, lgdp, nu = 2, mse.RANGE = 0.05, kn = 2, bb = 1)


g.ker = kern.reg(lgdp, result$b0, kernel = "epanech")
g0 = result$g0
g0.der1 = result.der1
g0.der2 = result.der2

res = lgdp - g0

df = data.frame(cbind(year, g0, g0.der1, g0.der2, g.ker, res))

plot.trend <- ggplot(df, aes(x = year, y = lgdp)) + 
  geom_line(aes(color = "Log of GDP"), size = 0.25) +
  geom_line(aes(y = g0, color = "Trend (local linear)"), size = 0.25) +
  geom_line(aes(y = g.ker, color = "Trend (kernel)"), size = 0.25, linetype = "dashed") +
  labs(title = "(a) Log of US-GDP & estimated trends", y = "Log-GDP and trends") + 
  scale_x_continuous(name = "", breaks = seq(1945, 2020, 10)) +
  scale_color_manual(name = "Lines:",
                     breaks = c("Log of GDP", "Trend (local linear)", "Trend (kernel)"),
                     values = c("Log of GDP" = "black", "Trend (local linear)" = "red", "Trend (kernel)" = "blue")) +
  theme(legend.position = c(0.1275, 0.81), legend.key.size = unit(0.35, "cm"),
        legend.text = element_text(size = 6), legend.title = element_text(size = 8),
        legend.background = element_rect(colour = 'black', fill = 'white', linetype='solid', size = 0.25),
        plot.title = element_text(hjust = 0.5), axis.title.y = element_text(size = 9), axis.title.x = element_blank(), 
        axis.text.y = element_text(size = 7), axis.text.x = element_blank(), axis.ticks.x = element_blank(),
        axis.ticks = element_line(size = 0.25), panel.grid.major = element_line(size = 0.25)) +
  guides(color = guide_legend(override.aes = list(size = 0.2)))

plot.der1 <- ggplot(df, aes(x = year, y = g0.der1)) + 
  geom_line(size = 0.25) +
  labs(title = "(c) Estimated first derivative", y = "1st derivative", x = "") +
  scale_x_continuous(name = "", breaks = seq(1945, 2020, 10)) +
  theme(plot.title = element_text(hjust = 0.5), axis.title = element_text(size = 9), axis.title.x = element_blank(), 
        axis.text.y = element_text(size = 7), axis.text.x = element_blank(), axis.ticks.x = element_blank(),
        axis.ticks = element_line(size = 0.25), panel.grid.major = element_line(size = 0.25))

plot.res <- ggplot(df, aes(x = year, y = res)) +
  geom_line(size = 0.25) + 
  labs(title = "(b) Trend-adjusted Residuals (local linear)", y = "Resiudals", x = "Year") +
  scale_x_continuous(name = "Year", breaks = seq(1945, 2020, 10)) +
  theme(plot.title = element_text(hjust = 0.5), axis.title = element_text(size = 9),
        axis.text = element_text(size = 7), axis.ticks = element_line(size = 0.25),
        panel.grid.major = element_line(size = 0.25))

plot.der2 <- ggplot(df, aes(x = year, y = g0.der2)) +
  geom_line(size = 0.25) +
  geom_hline(yintercept = 0, size = 0.25) +
  labs(title = "(d) Estimated second derivative", y = "2nd derivative", x = "Year") +
  scale_x_continuous(name = "Year", breaks = seq(1945, 2020, 10)) +
  theme(plot.title = element_text(hjust = 0.5), axis.title = element_text(size = 9),
        axis.text = element_text(size = 7), axis.ticks = element_line(size = 0.25),
        panel.grid.major = element_line(size = 0.25))

ggpubr::ggarrange(plot.trend, plot.der1, plot.res, plot.der2, heights = c(0.9, 1), nrow = 2, ncol = 2)  
ggsave("USgdp.pdf", height = 5, width = 9.5, dpi = 600)
