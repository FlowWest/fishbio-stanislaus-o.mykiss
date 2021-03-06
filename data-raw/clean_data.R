library(tidyverse)
library(readr)

# save cleaned data to `data/`

# weir passage data ------------------------------------------------------------
weir_passage_2020 <- read_csv("data-raw/FISHBIO_submission/FISHBIO_RBT_weir_passages.csv") %>%
  janitor::clean_names() %>%
  rename(fish_condition = condition) %>%
  glimpse

#view(weir_passage_2020)

weir_passage_2020$`vaki_trap`%>% unique()

cleaned_passage_data_2020 <- weir_passage_2020  %>%
  mutate(passage_date = as.Date(passage_date, "%m/%d/%y")) %>%
  mutate_if(is.character, tolower)

cleaned_passage_data_2020$passage_direction %>% unique()
cleaned_passage_data_2020$vaki_trap %>% unique()


weir_passage_2022 <- read_csv("data-raw/FISHBIO_submission/FISHBIO_passage_2021-22.csv") %>%
  janitor::clean_names() %>%
  select(-entered_by, -qcd_by) %>%
  glimpse

cleaned_passage_data_2022 <- weir_passage_2022  %>%
  mutate_if(is.character, tolower) %>%
  mutate(passage_date = as.Date(passage_date, "%m/%d/%y"),
         vaki_trap = ifelse(vaki_trap == "trapping", "trap", vaki_trap)) %>%
  glimpse

cleaned_passage_data_2022$passage_direction %>% unique()
cleaned_passage_data_2022$vaki_trap %>% unique()

# Combine Weir passage data

weir_passage <- bind_rows(cleaned_passage_data_2020, cleaned_passage_data_2022) %>%
  mutate(ad_clip = case_when(ad_clip %in% c("y", "yes") ~ "yes",
                             ad_clip %in% c("n", "no") ~ "no"),
         video_problems = ifelse(video_problems == "n/a", NA_character_, video_problems)) %>% glimpse


weir_passage$passage_date %>% summary()
weir_passage$passage_time %>% summary()
weir_passage$passage_direction %>% table(useNA = "ifany")
weir_passage$species %>% table(useNA = "ifany")
weir_passage$body_depth %>% summary()
weir_passage$length_coefficient %>% summary()
weir_passage$total_length %>% summary()
weir_passage$life_stage %>% table(useNA = "ifany")
weir_passage$count %>% summary()
weir_passage$sex %>% table(useNA = "ifany")
weir_passage$ad_clip %>% table(useNA = "ifany")
weir_passage$fish_condition %>% table(useNA = "ifany") #TODO ask about fish condition
weir_passage$id_certainty %>% table(useNA = "ifany")
weir_passage$video_quality %>% table(useNA = "ifany")
weir_passage$video_problems %>% table(useNA = "ifany")
weir_passage$vaki_trap %>% table(useNA = "ifany")

weir_passage$comments %>% table(useNA = "ifany")

clean_weir_passage <- weir_passage %>%
  mutate(comments = gsub(",", ";", comments))

clean_weir_passage$comments %>% table(useNA = "ifany")

# write_csv(clean_weir_passage, "data/FISHBIO_RBT_weir_passages_2005_2022.csv")

# Pit tag data -----------------------------------------------------------------
raw_pit_tag <- read_csv("data-raw/FISHBIO_submission/FISHBIO_PIT Tag Detections_2021-22.csv") %>% glimpse

clean_pit_tag <- raw_pit_tag %>%
  janitor::clean_names() %>%
  rename(pit_number = pit_num) %>%
  mutate(date = as.Date(date, "%m/%d/%y"),
         tag_date = as.Date(tag_date, "%m/%d/%y")) %>%
  mutate_if(is.character, tolower) %>%
  glimpse

# TODO: figure out time of 31 hours...

# write_csv(clean_pit_tag, "data/FISHBIO_PIT_tag_detections_2021_2022.csv")


# trapping ---------------------------------------------------------------------

raw_trapping_data <- read_csv("data-raw/FISHBIO_submission/FISHBIO_trapping_2021-22.csv") %>% glimpse

clean_trap <- raw_trapping_data %>%
  janitor::clean_names() %>%
  rename(fork_length = forklength) %>%
  select(-fish_condition) %>%
  rename(fish_condition = conditon) %>%
  mutate_if(is.character, tolower) %>%
  mutate(pit_tag = c("pit tag #982091062594309", "pit tag #982091062594274"),
         weight = c(2.5, 2.6),
         floy_tag = c("floy tag #001", "floy tag #002"),
         ad_clip = ifelse(ad_clip == "y", "yes", "no"),
         scales = ifelse(scales == "y", "yes", "no"),
         genetic = ifelse(genetic == "y", "yes", "no"),
         recapture = ifelse(ad_clip == "y", "yes", "no")) %>%
  select(-comments) %>%
  glimpse()

clean_trap$fish_condition %>% table(useNA = "ifany")

# write_csv(clean_trap, "data/FISHBIO_trapping_2021.csv")

# Operations Logs
# Weir operations log -----------------------------------------------------------
weir_operations_log <- read_csv("data-raw/FISHBIO_submission/FISHBIO_Weir operations log_2021-22.csv") %>% glimpse

clean_weir_operations <- weir_operations_log %>%
  janitor::clean_names() %>%
  mutate(sample_date = as.Date(sample_date, "%m/%d/%y"),
         comments1 = gsub(",", ";", comments1),
         crew_initials = gsub(",", ";", crew_initials)) %>%
  mutate_if(is.character, tolower) %>%
  rename(downstream_livebox_installed = downstream_livebox_installed_y_n,
         vaki = vaki_y_n,
         barrels = barrels_y_n) %>%
  mutate(downstream_livebox_installed = tolower(downstream_livebox_installed),
         vaki = tolower(vaki),
         barrels = tolower(barrels),
         trapping = tolower(trapping)) %>%
  select(-condition_code) %>%
  glimpse()

#write_csv(clean_weir_operations, "data/FISHBIO_Weir_operations_log_2021_2022.csv")

# PIT operations log ------------------------------------------------------------
pit_operations_log <- read_csv("data-raw/FISHBIO_submission/FISHBIO_PIT Operations Log 2021-22.csv") %>% glimpse()

clean_pit_tag_operations <- pit_operations_log %>% janitor::clean_names() %>%
  mutate(date = as.Date(date, "%m/%d/%y"),
         operational_mode = case_when(operational_mode == "Stpooed" ~ "Stopped",
                                      TRUE ~ as.character(operational_mode)),
         operational_mode = tolower(operational_mode),
         description = gsub(",", ";", description),
         description = tolower(description)) %>%
  glimpse

unique(clean_pit_tag_operations$operational_mode)
unique(clean_pit_tag_operations$description)

#write_csv(clean_pit_tag_operations, "data/FISHBIO_Pit_operations_log_2021_2022.csv")

