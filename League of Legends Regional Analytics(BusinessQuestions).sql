-- Q1 Which region has the most balanced gameplay in terms of average win rate, KDA, pick rate, and ban rate across all champions?
SELECT Region, AVG(WinRate) AS AvgWinRate, AVG(KDA) AS AvgKDA, AVG(PickRate) AS AvgPickRate, AVG(BanRate) AS AvgBanRate
FROM ( SELECT 'EUW' AS Region, WinRate, KDA, PickRate, BanRate FROM ChampionStats_EUW
    UNION ALL
    SELECT 'NA', WinRate, KDA, PickRate, BanRate FROM ChampionStats_NA
	UNION ALL
    SELECT 'JP', WinRate, KDA, PickRate, BanRate FROM ChampionStats_JP
    UNION ALL
    SELECT 'KR', WinRate, KDA, PickRate, BanRate FROM ChampionStats_KR
    UNION ALL
    SELECT 'TW', WinRate, KDA, PickRate, BanRate FROM ChampionStats_TW
) AS Combined
GROUP BY Region
ORDER BY AvgWinRate DESC;

-- Q2 How do champions rank in terms of overall performance when considering average KDA, win rate, and pick rate across all regions?
SELECT c.Champion, 
       AVG(cs.KDA) AS AvgKDA, 
       AVG(cs.WinRate) AS AvgWinRate, 
       AVG(cs.PickRate) AS AvgPickRate,
       RANK() OVER (ORDER BY AVG(cs.KDA) DESC, AVG(cs.WinRate) DESC, AVG(cs.PickRate) DESC) AS PerformanceRank
FROM (SELECT Championstatsid, KDA, WinRate, PickRate FROM ChampionStats_EUW
      UNION ALL
      SELECT Championstatsid, KDA, WinRate, PickRate FROM ChampionStats_NA
      UNION ALL
      SELECT Championstatsid, KDA, WinRate, PickRate FROM ChampionStats_JP
      UNION ALL
      SELECT Championstatsid, KDA, WinRate, PickRate FROM ChampionStats_KR
      UNION ALL
      SELECT Championstatsid, KDA, WinRate, PickRate FROM ChampionStats_TW) cs
JOIN Champions c ON cs.Championstatsid = c.ChampionID
GROUP BY c.Champion;

-- Q3 Which champion is most favored across all regions, and how does this preference correlate with their win rate and KDA?
SELECT c.Champion, MAX(cs.PickRate) AS HighestPickRate, WinRate, KDA
FROM (
    SELECT Championstatsid, PickRate, WinRate, KDA FROM ChampionStats_EUW
    UNION ALL
    SELECT Championstatsid, PickRate, WinRate, KDA FROM ChampionStats_NA
    UNION ALL
    SELECT Championstatsid, PickRate, WinRate, KDA FROM ChampionStats_JP
    UNION ALL
    SELECT Championstatsid, PickRate, WinRate, KDA FROM ChampionStats_KR
    UNION ALL
    SELECT Championstatsid, PickRate, WinRate, KDA FROM ChampionStats_TW
) cs
JOIN Champions c ON cs.Championstatsid = c.ChampionID
GROUP BY c.Champion, WinRate, KDA
ORDER BY HighestPickRate DESC
LIMIT 1;

-- Q4 How does the average gold earned by champions in the TW region compare across different win rate brackets?
SELECT WinRateBracket, AVG(Gold) AS AvgGold
FROM (
    SELECT CASE
            WHEN WinRate BETWEEN 0 AND 0.1 THEN '0-10%'
			WHEN WinRate BETWEEN 0.1 AND 0.2 THEN '10-20%'
			WHEN WinRate BETWEEN 0.3 AND 0.4 THEN '30-40%'	
            WHEN WinRate BETWEEN 0.4 AND 0.5 THEN '40-50%'
            WHEN WinRate BETWEEN 0.5 AND 0.6 THEN '50-60%'
            ELSE 'Above 60%'
        END AS WinRateBracket, Gold
    FROM ChampionStats_TW
) AS Brackets
GROUP BY WinRateBracket
ORDER BY  CASE WinRateBracket
        WHEN '0-10%' THEN 1
        WHEN '10-20%' THEN 2
		WHEN '20-30%' THEN 3
		WHEN '30-40%' THEN 4
        WHEN '40-50%' THEN 5
		WHEN '50-60%' THEN 6
        ELSE 7. end; 


-- Q5 In the EUW region, which champions most frequently achieve a KDA above 3, and how does this reflect on their overall performance?
SELECT c.Champion, 
       COUNT(CASE WHEN cs.KDA > 5 THEN 1 END) AS HighKDAOccurrences
FROM ChampionStats_EUW cs
JOIN Champions c ON cs.Championstatsid = c.ChampionID
GROUP BY c.Champion
ORDER BY HighKDAOccurrences DESC;

-- Q6 Which champion in the KR region has the highest average CS 
SELECT Champion, MAX(CS) AS HighestCS
FROM ChampionStats_KR cs
 JOIN Champions c ON cs.Championstatsid = c.ChampionID
GROUP BY c.Champion
ORDER BY HighestCS DESC
LIMIT 1;

-- Q7 Is there a significant difference in the average KDA between champions in the EUW and NA regions? 
SELECT c.Champion, AVG(csEUW.KDA) AS AvgKDA_EUW, AVG(csNA.KDA) AS AvgKDA_NA
FROM Champions c
LEFT JOIN ChampionStats_EUW csEUW ON c.ChampionID = csEUW.Championstatsid
LEFT JOIN ChampionStats_NA csNA ON c.ChampionID = csNA.Championstatsid
GROUP BY c.Champion;


-- Q8 How does the pick rate of champions in the TW region correlate with their games played, and which champions are picked frequently but rarely banned?
SELECT c.Champion, cs.PickRate, cs.BanRate, GamesPlayed,
    CASE WHEN cs.PickRate > 0.1 AND cs.BanRate < 0.05 THEN 'Frequently Picked'
        ELSE 'Other'
    END AS PickBanCategory
FROM ChampionStats_TW cs
JOIN Champions c ON cs.Championstatsid = c.ChampionID
ORDER BY cs.PickRate DESC, GamesPlayed DESC;

