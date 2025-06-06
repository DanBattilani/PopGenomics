#---------------------------------------------------------------
# Plotting Nucleotide Diversity (π) from VCFtools Output (3 pops example)
#---------------------------------------------------------------

# Required package
library(ggplot2)

#---------------------------------------------------------------
# Setup: Set working directory to where your .windowed.pi files are stored
#---------------------------------------------------------------
setwd("C:/path/no_admixed")  # <-- Update this path as needed

#---------------------------------------------------------------
# Data Import
#---------------------------------------------------------------
# Read VCFtools windowed π output files for each population
WIT_1Mb <- read.table('WIT_1Mb.windowed.pi', header = TRUE, sep = '\t')
WSC_1Mb <- read.table('WSC_1Mb.windowed.pi', header = TRUE, sep = '\t')
WUS_1Mb <- read.table('WUS_1Mb.windowed.pi', header = TRUE, sep = '\t')

#---------------------------------------------------------------
# Annotate and Combine Data
#---------------------------------------------------------------
# Add population labels
WIT_1Mb$Population <- 'WIT'
WSC_1Mb$Population <- 'WSC'
WUS_1Mb$Population <- 'WUS'

# Combine into a single dataframe
TOT_1Mb <- rbind(WIT_1Mb, WSC_1Mb, WUS_1Mb)

# Create a composite position string for x-axis labeling (not ideal for large data, use with caution)
TOT_1Mb$POS <- paste(TOT_1Mb$CHROM, TOT_1Mb$BIN_START, TOT_1Mb$BIN_END, sep = "_")

#---------------------------------------------------------------
# Plotting
#---------------------------------------------------------------
# Visualize nucleotide diversity by population and genome window
ggplot(data = TOT_1Mb, aes(x = POS, y = PI, color = Population, fill = Population)) +
  geom_bar(stat = "identity") +
  scale_color_manual(values = c("WIT" = "#00BA42", "WSC" = "#9F28BD", "WUS" = "#D95F02")) +
  scale_fill_manual(values = c("WIT" = "#00BA42", "WSC" = "#9F28BD", "WUS" = "#D95F02")) +
  labs(
    x = "Genomic Window (CHR_START_END)",
    y = "Nucleotide Diversity (π)",
    title = "Windowed Nucleotide Diversity (1Mb) by Population"
  ) +
  facet_wrap(~Population, ncol = 1, scales = "free_x") +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_blank(),  # Hide x-axis text for clarity
    axis.ticks.x = element_blank(),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10)),
    strip.text = element_text(face = "bold")
  )

#---------------------------------------------------------------
# Summary Statistics
#---------------------------------------------------------------
# Calculate and print mean and SD of nucleotide diversity per population
cat("WIT mean π:", mean(WIT_1Mb$PI), " | SD:", sd(WIT_1Mb$PI), "\n")
cat("WSC mean π:", mean(WSC_1Mb$PI), " | SD:", sd(WSC_1Mb$PI), "\n")
cat("WUS mean π:", mean(WUS_1Mb$PI), " | SD:", sd(WUS_1Mb$PI), "\n")
