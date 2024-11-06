-- SQL Advanced project -- Spotify Dataset\
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA

Select Count (*) from spotify;
Select Count(Distinct Artist) from spotify;
Select Count(Distinct Album) from spotify;
Select Distinct Album_type from spotify;
Select Max(duration_min) from spotify;
Select min(duration_min) from spotify;

Select * from spotify where duration_min = 0;

Delete from Spotify where duration_min=0;

Select distinct channel from spotify;

Select distinct most_played_on from spotify;

/*
-- Data analysis 

Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/
-------------------------------------

Select * from spotify where stream > 1000000000;

Select Distinct album,artist from spotify order by 1;

Select Distinct album from spotify order by 1;

Select Count(comments) from spotify where licensed = 'true';
Select Sum(comments) from spotify where licensed = 'true';

Select * from spotify where album_type = 'single';

Select artist,--1
count(*) as total_no_songs --2
from spotify group by artist order by 2 Desc;

/*
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.

*/

Select album,
Avg(danceability) as Avg_danceability
from spotify group by 1
order by 2 desc;

Select track,
max(energy) as highest_energy_levels from spotify
group by 1 order by 2 desc limit 5;


Select track,
Sum(views) as total_views,
Sum(likes) total_likes
from spotify 
where official_video = 'true'
group by 1
order by 2 desc
limit 5;

Select album,
track,
sum(views) as total_views
from spotify
group by 1,2
order by 3 desc;


Select 
* from
(Select track,
Coalesce(sum(case when most_played_on ='Youtube' then stream end),0) AS streamed_on_youtube,
Coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) AS streamed_on_spotify
from spotify
group by track ) AS T1
where 
streamed_on_spotify > streamed_on_youtube
and 
streamed_on_youtube <> 0;

Select * from spotify

/*
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

With Ranking_artist
AS
(Select Artist,
Track,
Sum(Views) as total_view,
DENSE_RANK() Over(Partition by Artist order by Sum(Views)Desc) As rank
from spotify
group by 1,2
order by 1,3 Desc)
Select * from Ranking_artist where rank <=3;


Select * from spotify;

Select Avg(liveness) from spotify;


Select Track, Artist,liveness from spotify where liveness > (Select Avg(liveness) from spotify);

With cte
AS
(Select album,
MAX(energy) AS Highest_energy,
MIN(energy) AS Lowest_energy
from Spotify Group by 1)
Select Album,
Highest_energy - lowest_energy as energy_difference
from cte
order by 2 Desc;

Select track,energy,
liveness,
(energy/liveness) AS energy_liveness_ratio
from spotify
where (energy/liveness) > 1.2;

Select track,
views,
SUM(likes) Over(order by views Rows Between unbounded preceding and current row) As cumulative_total
from spotify
order by views;

Explain Analyze
Select artist,
track,
views from spotify where artist = 'Gorillaz' And most_played_on = 'Youtube' order by stream DESC limit 25;

Create Index Artist_Index on spotify(artist);
