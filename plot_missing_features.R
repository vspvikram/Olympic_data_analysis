plot_missing_features <- function(DataFrame, percent=FALSE) {
  missing_patterns <- data.frame(is.na(DataFrame)) %>%
    group_by_all() %>%
    count(name = "count", sort = TRUE) %>%
    ungroup()
  
  # Changing the wide format data frame to long format data frame.
  long_format_na <- subset(missing_patterns, select=-c(count)) %>%
    rownames_to_column() %>% 
    gather(col_name, value, -rowname)
  
  long_format_na <- long_format_na %>% mutate(col_name = factor(col_name))
  
  
  # Getting the rows which have zero null values
  complete_rows <- rowSums(subset(missing_patterns, select=-c(count)))
  complete_rows_indices <- which(complete_rows %in% c(0))
  
  # Making the first plot
  plot_1 <- ggplot(data=long_format_na,) + 
    geom_tile(aes(x=fct_reorder(col_name, -value, sum), 
                  y=fct_rev(rowname), 
                  fill=value),
              color = "white",
              lwd = 1.2,
              linetype = 1) + 
    scale_fill_manual(values=c('gray', 'orchid4')) +
    new_scale_fill()+
    geom_tile(data=long_format_na[long_format_na$rowname %in% complete_rows_indices,],
              aes(x=col_name,
                  y=rowname,
                  color='gray',
                  alpha=0.6)) + 
    annotate("text",
             x = (length(colnames(missing_patterns)) - 1)/2,
             y = nrow(missing_patterns) - complete_rows_indices[1] + 1,
             label = "Complete Cases",
             color = 'darkblue') +
    labs(x='Variables', 
         y='Missing Pattern', 
         colour='Missing Values',) +
    theme(legend.position = "none")
  
  # Making the second plot
  missing_columns_percentage <- data.frame(colSums(is.na(DataFrame)) %>% sort(decreasing=T))
  missing_columns_percentage <-  rownames_to_column(missing_columns_percentage)
  print(missing_columns_percentage)
  colnames(missing_columns_percentage) <-  c("variable", "missing_percent")
  if (percent) {
    missing_columns_percentage$missing_percent <- 100 * missing_columns_percentage$missing_percent / nrow(DataFrame) 
    y_label <- '% Row Missing'
  } else {
    y_label <- 'Num Rows Missing'
  }
  
  missing_columns_percentage <- missing_columns_percentage[order(-missing_columns_percentage$missing_percent),]
  
  print('Plotted 1')
  
  if (percent) {
    plot_2 <- ggplot(data=missing_columns_percentage, 
                     aes(x=fct_reorder(variable, -missing_percent), 
                         y=missing_percent)) + 
      geom_bar(stat='identity', 
               fill='slateblue', 
               alpha=0.9) + 
      labs(x='Variables', 
           y=y_label) +
      scale_y_continuous(limits = c(0,100))
  } else {
    plot_2 <- ggplot(data=missing_columns_percentage, 
                     aes(x=fct_reorder(variable, -missing_percent), 
                         y=missing_percent)) + 
      geom_bar(stat='identity', 
               fill='slateblue', 
               alpha=0.9) + 
      labs(x='Variables', 
           y=y_label)
  }
  
  
  print('Plotted 2')
  # Making the third plot
  if (percent) {
    missing_patterns$count <- 100 * missing_patterns$count / (nrow(DataFrame))
    plot_3 <- ggplot(data=missing_patterns, 
                     aes(y=count, 
                         x=fct_reorder(row.names(missing_patterns), count))) + 
      geom_bar(stat='identity', 
               fill='slateblue', 
               alpha=0.9) + 
      labs(y='% Rows', 
           x=' ') +
      scale_y_continuous(limits = c(0,100)) +
      coord_flip()  
  } else { 
    plot_3 <- ggplot(data=missing_patterns, 
                     aes(y=count, 
                         x=fct_reorder(row.names(missing_patterns), count))) + 
      geom_bar(stat='identity', 
               fill='slateblue', 
               alpha=0.9) + 
      labs(y='Rows Count', 
           x=' ') + 
      coord_flip()
  }
  
  
  # Choosing the layout
  layout <- "
  BBBBB#
  BBBBB#
  BBBBB#
  AAAAAC
  AAAAAC
  AAAAAC
  AAAAAC
  AAAAAC
  "
  
  # Creating the final plot
  plot_1 + plot_2 + plot_3 + plot_layout(design=layout) +
    plot_annotation(
      title = "Missing value patterns"
    )
}