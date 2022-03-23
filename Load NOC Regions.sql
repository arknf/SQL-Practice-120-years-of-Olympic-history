LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/noc_regions.csv' 
INTO TABLE athlete_events
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;