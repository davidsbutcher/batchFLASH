
#' run_batch_FD
#'
#' @param inputDir
#' @param outputDir
#' @param FDargs
#'
#' @return
#'
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#'

run_batch_FD <-
   function(
      inputDir,
      outputDir,
      FDargs = c("-RTwindow 20", "-minRTspan 3")
   ) {


      # Assertions --------------------------------------------------------------

      if (file.exists(inputDir) == FALSE) {

         assertthat::assert_that(
            assertthat::is.dir(outputDir),
            msg = "outputDir is not a recognized path"
         )

      }

      assertthat::assert_that(
         assertthat::is.dir(dirname(outputDir)),
         msg = "outputDir parent is not a recognized path"
      )

      # Check for existing FLASHDeconv results ----------------------------------

      if (dir.exists(outputDir) == FALSE) dir.create(outputDir)

      ## Determine expected output based on input dir or file

      if (dir.exists(inputDir) == TRUE) {

         expected_output <-
            fs::dir_ls(
               inputDir,
               glob = "*.mzML"
            ) %>%
            purrr::map_chr(
               fs::path_ext_remove
            ) %>%
            purrr::map_chr(
               basename
            ) %>%
            purrr::map_chr(
               ~paste0(.x, ".tsv")
            )

      } else {

         expected_output <-
            inputDir %>%
            purrr::map_chr(
               fs::path_ext_remove
            ) %>%
            purrr::map_chr(
               basename
            ) %>%
            purrr::map_chr(
               ~paste0(.x, ".tsv")
            )

      }

      ## Determine existing output

      existing_output <-
         fs::dir_ls(
            outputDir,
            glob = "*.tsv"
         ) %>%
         purrr::map_chr(
            basename
         )

      ## If expected output is found, do not run FLASHDeconv

      if (length(existing_output) == 0) {

         FD_done <- FALSE

      } else if (all(expected_output %in% existing_output) == TRUE) {

         message("FLASHDeconv results found, skipping decon.")

         FD_done <- TRUE

      } else {

         FD_done <- FALSE

      }


      # Process paths -----------------------------------------------------------

      # Process paths -----------------------------------------------------------

      inputDir_sys2 <-
         paste0("\"", inputDir, "\"")

      outputDir_sys2 <-
         paste0("\"", outputDir, "/\"")


      # Run FLASHDeconv ---------------------------------------------------------

      if (FD_done == FALSE) {

         system2(
            system.file(
               "bin",
               "FLASHDeconv.exe",
               package = "batchFLASH"
            ),
            args = paste(
               glue::glue("-in {inputDir_sys2} -out {outputDir_sys2}"),
               FDargs,
               collapse = " "
            ),
            stdout =
               glue::glue("{outputDir}/console_output.txt")
         )

      }


      # Reduce all output -------------------------------------------------------

      tsv_list <-
         fs::dir_ls(outputDir, glob = "*.tsv")

      FD_output <-
         tsv_list %>%
         purrr::map(
            readr::read_tsv
         ) %>%
         purrr::reduce(dplyr::union_all) %>%
         dplyr::mutate(
            Fraction = dplyr::case_when(
               stringr::str_detect(
                  FileName,
                  "(?i)(?<=gf|gf_|peppi|peppi_|frac|fraction|f|f_)[0-9]{1,2}"
               ) == TRUE ~
                  stringr::str_extract(
                     FileName,
                     "(?i)(?<=gf|gf_|peppi|peppi_|frac|fraction|f|f_)[0-9]{1,2}"
                  ),
               TRUE ~ "NA"
            )
         )

      # Plot output -------------------------------------------------------------

      ## Overlaid

      FD_output %>%
         dplyr::mutate(MonoisotopicMass = MonoisotopicMass/1000) %>%
         ggplot2::ggplot(ggplot2::aes(MonoisotopicMass, 0, color = Fraction, size = 0.25)) +
         ggplot2::geom_segment(ggplot2::aes(xend = MonoisotopicMass, yend = SumIntensity)) +
         ggplot2::theme_minimal() +
         ggplot2::scale_x_continuous(limits = c(0,60), breaks = scales::breaks_pretty()) +
         ggplot2::scale_y_continuous(breaks = scales::breaks_pretty(n = 3)) +
         ggplot2::scale_size_identity() +
         ggplot2::scale_color_manual(
            values =
               c("#FFD700","#A020F0","#FF8D00", "#0000FF", "#FF0000", "#00FF00", "#FF00FF", "#00FFFF", "#B3B3B3")
         ) +
         ggplot2::labs(x = "Monoisotopic Mass (kDa)", y = "Summed Intensity") +
         ggplot2::theme(
            text = ggplot2::element_text(size = 12),
            strip.text.x = ggplot2::element_blank()
         )

      ggplot2::ggsave(
         paste0(
            outputDir,
            glue::glue("/FLASHDeconv_{basename(outputDir)}_mass_vs_intesity_overlaid.pdf")
         ),
         bg = "transparent",
         height = 5,
         width = 8
      )

      unique_filename_count <-
         FD_output$FileName %>%
         unique() %>%
         length()

      fraction_count <-
         FD_output$Fraction %>%
         unique() %>%
         as.numeric() %>%
         length()

      if (unique_filename_count > 1) {

         ## Facetted

         FD_output %>%
            dplyr::mutate(MonoisotopicMass = MonoisotopicMass/1000) %>%
            ggplot2::ggplot(ggplot2::aes(MonoisotopicMass, 0, color = Fraction, size = 0.25)) +
            ggplot2::geom_segment(ggplot2::aes(xend = MonoisotopicMass, yend = SumIntensity)) +
            ggplot2::theme_minimal() +
            ggplot2::scale_x_continuous(limits = c(0,60), breaks = scales::breaks_pretty()) +
            ggplot2::scale_y_continuous(breaks = scales::breaks_pretty(n = 3)) +
            ggplot2::scale_size_identity() +
            ggplot2::scale_color_manual(
               values =
                  c("#FFD700","#A020F0","#FF8D00", "#0000FF", "#FF0000", "#00FF00", "#FF00FF", "#00FFFF", "#B3B3B3")
            ) +
            ggplot2::labs(x = "Monoisotopic Mass (kDa)", y = "Summed Intensity") +
            ggplot2::facet_wrap(~Fraction, ncol = 1) +
            ggplot2::theme(
               text = ggplot2::element_text(size = 12),
               strip.text.x = ggplot2::element_blank(),
               panel.spacing = ggplot2::unit(1, "lines")
            )

         ggplot2::ggsave(
            paste0(
               outputDir,
               glue::glue("/FLASHDeconv_{basename(outputDir)}_mass_vs_intesity_facetted.pdf")
            ),
            bg = "transparent",
            height = 1.5 * fraction_count,
            width = 8
         )

      }

      # Save arguments ----------------------------------------------------------

      readr::write_lines(
         FDargs,
         paste0(
            outputDir,
            glue::glue("/FLASHDeconv_{basename(outputDir)}_arguments.txt")
         )
      )

   }
