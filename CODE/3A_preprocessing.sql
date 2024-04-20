--STEP 1: SELECT DISTINCT PLAYER-GAMES FROM PITCH DATA
select distinct player_name,game_date
into #STEP1
from #CombinedPitchData

--STEP2: MERGE INJURY DATE TO THE PLAYER-GAMES DATA
select a.*,b.IL_Retro_Date
into #STEP2
from #STEP1 a left join #InjuryMaster b
on a.player_name=b.pitchdata_player_name
where b.INCLUDE = 'Y';

--STEP 3: CALCULATE DATE INTERVAL BETWEEN GAMEDATE & INJURYDATE
select *, DATEDIFF(day,IL_Retro_Date,game_date) as DaysBtwnInjury
into #STEP3
from #STEP2;
--VALIDATE STEP 3
select * from #STEP3
order by player_Name,IL_Retro_Date,game_date;

--STEP 4 PRE: FILTER FOR PRE-INJURY GAMES
select *
into #STEP4pre
from #STEP3
where DaysBtwnInjury <= 0;
--VALIDATE STEP 4 PRE
select * from #STEP4pre
order by player_Name,IL_Retro_Date,game_date;

--STEP 4 POST: FILTER FOR POST-INJURY GAMES
select *
into #STEP4post
from #STEP3
where DaysBtwnInjury > 0;
--VALIDATE STEP 4 POST
select * from #STEP4post
order by player_Name,IL_Retro_Date,game_date;

--STEP 5 PRE: RANK DAYSBTWNINJURY FOR PRE-INJURY GAMES. THIS WILL HELP IDENTIFY MOST RECENT GAMES LEADING
UP TO THE INJURY
select *,RANK() OVER(PARTITION BY player_Name,IL_Retro_Date order by DaysBtwnInjury desc) as DaysRk
into #STEP5pre
from #STEP4pre;
--VALIDATE STEP 5 PRE
select * from #STEP5pre
order by player_Name,IL_Retro_Date,game_date;

--STEP 5 POST: RANK DAYSBTWNINJURY FOR POST-INJURY GAMES. THIS WILL HELP IDENTIFY MOST RECENT GAMES AFTER
RETURNING FROM THE INJURY
select *,RANK() OVER(PARTITION BY player_Name,IL_Retro_Date order by DaysBtwnInjury) as DaysRk
into #STEP5post
from #STEP4post;
--VALIDATE STEP 5 POST
select * from #STEP5post
order by player_Name,IL_Retro_Date,game_date;

--STEP 6 PRE: REMOVE RANKS ABOVE 20 FOR PRE-INJURY GAMES. THE AVERAGE MLB PITCHER APPEARS IN 
ABOUT 20 GAMES PER SEASON. WE CHOSE TO EXCLUDE GAMES OUTSIDE THIS RANGE TO SHOW ONE "FULL SEASON" BEFORE
AND AFTER THE INJURY
select *,'PRE-INJURY' as PRE_POST
into #STEP6pre
from #STEP5pre
where DaysRk <= 20;
--VALIDATE STEP 6 PRE
select * from #STEP6pre
order by player_Name,IL_Retro_Date,game_date;

--STEP 6 POST: REMOVE RANKS ABOVE 20 FOR POST-INJURY GAMES.
select *,'POST-INJURY' as PRE_POST
into #STEP6post
from #STEP5post
where DaysRk <= 20;
--VALIDATE STEP 6 POST
select * from #STEP6post
order by player_Name,IL_Retro_Date,game_date;

--STEP 7: COMBINE PRE & POST INJURY DATA BACK TOGETHER
select * into #STEP7 from (
select * from #STEP6pre
UNION ALL
select * from #STEP6post) a;

--STEP 8: MERGE PITCH DATA TO OUR LIST OF THE 20 MOST RECENT GAMES 
PRE/POST INJURY FOR EACH PITCHER INJURY
select a.*
      ,b.pitch_type
      ,b.release_speed
      ,b.release_pos_x
      ,b.release_pos_z
      ,b.batter
      ,b.pitcher
      ,b.events
      ,b.description
      ,b.zone
      ,b.des
      ,b.game_type
      ,b.stand
      ,b.p_throws
      ,b.home_team
      ,b.away_team
      ,b.type
      ,b.hit_location
      ,b.bb_type
      ,b.balls
      ,b.strikes
      ,b.game_year
      ,b.pfx_x
      ,b.pfx_z
      ,b.plate_x
      ,b.plate_z
      ,b.on_3b
      ,b.on_2b
      ,b.on_1b
      ,b.outs_when_up
      ,b.inning
      ,b.inning_topbot
      ,b.hc_x
      ,b.hc_y
      ,b.fielder_2
      ,b.vx0
      ,b.vy0
      ,b.vz0
      ,b.ax
      ,b.ay
      ,b.az
      ,b.sz_top
      ,b.sz_bot
      ,b.hit_distance_sc
      ,b.launch_speed
      ,b.launch_angle
      ,b.effective_speed
      ,b.release_spin_rate
      ,b.release_extension
      ,b.game_pk
      ,b.pitcher_1
      ,b.fielder_2_1
      ,b.fielder_3
      ,b.fielder_4
      ,b.fielder_5
      ,b.fielder_6
      ,b.fielder_7
      ,b.fielder_8
      ,b.fielder_9
      ,b.release_pos_y
      ,b.estimated_ba_using_speedangle
      ,b.estimated_woba_using_speedangle
      ,b.woba_value
      ,b.woba_denom
      ,b.babip_value
      ,b.iso_value
      ,b.launch_speed_angle
      ,b.at_bat_number
      ,b.pitch_number
      ,b.pitch_name
      ,b.home_score
      ,b.away_score
      ,b.bat_score
      ,b.fld_score
      ,b.post_away_score
      ,b.post_home_score
      ,b.post_bat_score
      ,b.post_fld_score
      ,b.if_fielding_alignment
      ,b.of_fielding_alignment
      ,b.spin_axis
      ,b.delta_home_win_exp
      ,b.delta_run_exp
into #STEP8
from #STEP7 a
left join #CombinedPitchData b
on a.player_name=b.player_name
and a.game_date=b.game_date;

--STEP 9: CREATE A FLAG (TWENTYDAYWINDOW) WHICH ONLY FLAGS PLAYER-INJURIES WITH A FULL 20 GAMES BEFORE
& AFTER INJURY. THIS IS USEFUL IF ANALYZING AGGREGATED PRE/POST PERFORMANCE
select player_name,IL_Retro_Date, 'Y' as TwentyDayWindow, sum(RankCt) as RankCt 
into #STEP8_TWENTYFLAG
from (
select distinct player_name,IL_Retro_Date,DaysRk,PRE_POST,1 as RankCt from #STEP8 where DaysRk = 20
) a
group by player_name,IL_Retro_Date
 having sum(RankCt) = 2
 order by player_name,IL_Retro_Date

--STEP 10: JOIN TWENTYDAYWINDOW FLAG BACK TO DATASET
select a.*,b.TwentyDayWindow
into #STEP10
from #STEP8 a left join #STEP8_TWENTYFLAG b
on a.player_name=b.player_name AND a.IL_Retro_Date=b.IL_Retro_Date

--STEP11: CREATE A HIGHER LEVEL INJURY CATEGORY (INJURY_LOCATION)
select a.*
      ,b.Injury_Surgery
	  ,CASE
	  WHEN B.Injury_Surgery = 'Ankle contusion' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Ankle discomfort' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Ankle impingement' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Ankle inflammation' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Ankle surgery' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Ankle tendinitis' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Fractured ankle' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Sprained ankle' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Strained ankle' THEN 'Ankle'
		WHEN B.Injury_Surgery = 'Arm fatigue' THEN 'Arm'
		WHEN B.Injury_Surgery = 'Arm inflammation' THEN 'Arm'
		WHEN B.Injury_Surgery = 'Arm tightness' THEN 'Arm'
		WHEN B.Injury_Surgery = 'Stress reaction -- arm' THEN 'Arm'
		WHEN B.Injury_Surgery = 'Ablation procedure (back)' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back contusion' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back discomfort' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back soreness' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back spasms' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back stiffness' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back surgery' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back surgery (discectomy)' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back surgery (herniated disc)' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back surgery (lumbar discectomy)' THEN 'Back'
		WHEN B.Injury_Surgery = 'Back tightness' THEN 'Back'
		WHEN B.Injury_Surgery = 'Benign bone tumor in spine' THEN 'Back'
		WHEN B.Injury_Surgery = 'Cervical nerve impingement' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lat surgery' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lat tightness' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lower back discomfort' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lower back inflammation' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lower back spasm' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lower back spasms' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lower back surgery' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lower back tightness' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lumbar spasm' THEN 'Back'
		WHEN B.Injury_Surgery = 'Lumbar spine stress reaction' THEN 'Back'
		WHEN B.Injury_Surgery = 'Microdiscectomy (back surgery)' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained back' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained back (lumbar)' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained back (trapezius)' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained cervical spine' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained lat' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained lower back' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained lumbar' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained upper back' THEN 'Back'
		WHEN B.Injury_Surgery = 'Strained upper back (rhomboid)' THEN 'Back'
		WHEN B.Injury_Surgery = 'Stress fracture in lower back' THEN 'Back'
		WHEN B.Injury_Surgery = 'Stress fracture, lower back' THEN 'Back'
		WHEN B.Injury_Surgery = 'Stress reaction -- lower back' THEN 'Back'
		WHEN B.Injury_Surgery = 'Torn lat' THEN 'Back'
		WHEN B.Injury_Surgery = 'Torn lat tendon' THEN 'Back'
		WHEN B.Injury_Surgery = 'COVID-19' THEN 'Covid'
		WHEN B.Injury_Surgery = 'COVID-19 (protocol)' THEN 'Covid'
		WHEN B.Injury_Surgery = 'COVID-19 (symptoms)' THEN 'Covid'
		WHEN B.Injury_Surgery = 'COVID-19 (undisclosed)' THEN 'Covid'
		WHEN B.Injury_Surgery = 'COVID-19 (vaccination)' THEN 'Covid'
		WHEN B.Injury_Surgery = 'COVID-19 IL (undisclosed)' THEN 'Covid'
		WHEN B.Injury_Surgery = 'COVID-19 protocol' THEN 'Covid'
		WHEN B.Injury_Surgery = 'Arthoscopic elbow surgery' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Arthroscopic elbow surgery' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Blood clot removal surgery (right elbow)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Bone bruise in elbow' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Bone chip in elbow' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Bone spur in elbow' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow contusion' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow debridement surgery' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow discomfort' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow discomfort (lateral epicondylitis)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow discomfort (ulnar nerve entrapment)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow discomfort (ulnar neuritis)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow effusion' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow impingement' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow inflammation' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow laceration' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow nerve irritation' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow soreness' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow stress reaction' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (bone chip removal)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (bone chips)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (bone spur)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (flexor tendon/bone spur)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (fracture)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (hairline fracture)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (internal brace procedure)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (internal brace)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (loose bodies)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (loose body)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (stress fracture)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (UCL)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow surgery (ulnar nerve transposition)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow tendinitis' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow tightness' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow ulnar neuritis' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow valgus extension overload' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Elbow/Flexor tendon surgery (Tenex procedure)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Fractured elbow' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Fractured elbow (right)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Olecranon stress fracture (right elbow)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Partially torn elbow ligament' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Sprained elbow' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Strained elbow' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Strained elbow flexor' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Strained mass flexor' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Stress reaction -- elbow' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Tommy John revision surgery' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Tommy John surgery' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Tommy John surgery (revision)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Ulnar neuritis (elbow)' THEN 'Elbow'
		WHEN B.Injury_Surgery = 'Blister on foot' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Blister on toe' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Foot contusion' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Foot discomfort' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Foot metatarsalgia' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Foot surgery' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Fractured foot' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Fractured foot (fifth metatarsal)' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Fractured toe' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Plantar fascitis' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Sprained foot' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Sprained toe' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Stress reaction (toe)' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Toe sesamoiditis' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Turf toe' THEN 'Foot'
		WHEN B.Injury_Surgery = 'Blister -- finger (right index)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister (index finger)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister (middle finger)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister (right index finger)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister (right middle finger)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister on finger' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister on finger (left index)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister on finger (left)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister on finger (right index)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister on finger (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister on hand' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blister on right hand' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blisters (left hand)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Blisters (right hand)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Carpal tunnel syndrome surgery' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Cracked fingernail' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Cracked fingernail/blister' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Cracked nail (middle finger)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger contusion' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger contusion (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger discomfort' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger discomfort (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger inflammation (right index)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger inflammation (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger laceration' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger laceration (right index)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger laceration (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Finger surgery (left ring)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Fingernail avulsion (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Fractured finger' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Fractured finger (left ring)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Fractured finger (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Fractured hand (left)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Fractured hand (non-throwing)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Fractured hand (right pinkie)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Fractured hand (right)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Hand contusion' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Hand inflammation' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Non-displaced thumb fracture (right)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Ruptured finger pulley' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Split fingernail' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Sprained finger' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Sprained finger (left middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Sprained finger (left ring)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Sprained finger (right index)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Sprained finger (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Sprained left thumb' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Sprained thumb' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Strained finger' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Strained finger (left index)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Strained finger (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Thumb abrasion (right)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Thumb contusion' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Thumb surgery (laceration)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Thumb surgery (torn ligament)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Thumb weakness (left)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Torn finger tendon (right middle)' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Torn flexor tendon' THEN 'Hand'
		WHEN B.Injury_Surgery = 'Concussion' THEN 'Head'
		WHEN B.Injury_Surgery = 'Face surgery (OZMC fracture)' THEN 'Head'
		WHEN B.Injury_Surgery = 'Facial fractures' THEN 'Head'
		WHEN B.Injury_Surgery = 'Facial surgery' THEN 'Head'
		WHEN B.Injury_Surgery = 'Fractured nose' THEN 'Head'
		WHEN B.Injury_Surgery = 'Nasal fracture surgery' THEN 'Head'
		WHEN B.Injury_Surgery = 'Skull fracture' THEN 'Head'
		WHEN B.Injury_Surgery = 'Groin inflammation' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Groin tightness' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Hip discomfort' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Hip impingement' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Hip inflammation' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Hip surgery' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Hip surgery (labrum repair)' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Hip surgery (torn labrum)' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Hip tightness' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'SI joint inflammation' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'SI joint inflammation (hip)' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Sports hernia surgery' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Strained groin' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Strained hip' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Strained hip flexor' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Strained right groin' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Testicular contusion' THEN 'Hip/Groin'
		WHEN B.Injury_Surgery = 'Appendicitis' THEN 'Illness'
		WHEN B.Injury_Surgery = 'Flu-like symptoms' THEN 'Illness'
		WHEN B.Injury_Surgery = 'Illness' THEN 'Illness'
		WHEN B.Injury_Surgery = 'Mononucleosis' THEN 'Illness'
		WHEN B.Injury_Surgery = 'Non-COVID illness' THEN 'Illness'
		WHEN B.Injury_Surgery = 'Non-viral illness' THEN 'Illness'
		WHEN B.Injury_Surgery = 'Viral infection' THEN 'Illness'
		WHEN B.Injury_Surgery = 'Arthroscopic knee surgery' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee contusion' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee discomfort' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee effusion' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee inflammation' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee soreness' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery (cyst removal)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery (debridement)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery (loose bodies)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery (patellar tendon)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery (torn ACL)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery (torn meniscus)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery (torn patellar tendon)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee surgery (torn tendon)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Knee tendinitis' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Sprained knee' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Sprained knee (torn MCL)' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Strained knee' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Torn knee ligament' THEN 'Knee'
		WHEN B.Injury_Surgery = 'Flexor tendon surgery' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Flexor tendon/Tommy John revision surgery' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm contusion' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm discomfort' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm fatigue' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm inflammation' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm inflammtion' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm nerve inflammation' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm soreness' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm sugery (nerve decompression)' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm tendinitis' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Forearm tightness' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Hairline stress fracture (forearm)' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Radial nerve irritation' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Radial stress fracture, forearm)' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Sprained wrist' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Strained flexor' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Strained flexor tendon' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Strained forearm' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Strained forearm flexor' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Strained wrist' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Ulnar nerve irritation' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Ulnar nerve transposition surgery' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Ulnar neuritis' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Wrist contusion' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Wrist inflammation' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Wrist surgery' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Wrist surgery (fracture)' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Wrist tendinitis' THEN 'Lower Arm'
		WHEN B.Injury_Surgery = 'Achilles tendinitis' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Achilles'' tendon surgery' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Achilles'' tendon surgery (exploratory)' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Calf contusion' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Calf inflammation' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Leg discomfort' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Leg infection' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Lower leg tightness' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Patellar tendinitis' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Patellar tendonitis' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Shin contusion' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Strained calf' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Strained lower leg' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Stress reaction -- shin' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Stress reaction in leg' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Stress reaction to tibia' THEN 'Lower Leg'
		WHEN B.Injury_Surgery = 'Esophageal constriction' THEN 'Neck'
		WHEN B.Injury_Surgery = 'Neck discomfort' THEN 'Neck'
		WHEN B.Injury_Surgery = 'Neck inflammation' THEN 'Neck'
		WHEN B.Injury_Surgery = 'Neck nerve irritation' THEN 'Neck'
		WHEN B.Injury_Surgery = 'Neck spasms' THEN 'Neck'
		WHEN B.Injury_Surgery = 'Neck tightness' THEN 'Neck'
		WHEN B.Injury_Surgery = 'Strained neck' THEN 'Neck'
		WHEN B.Injury_Surgery = 'Anxiety' THEN 'Other'
		WHEN B.Injury_Surgery = 'Atrial fibrillation surgery' THEN 'Other'
		WHEN B.Injury_Surgery = 'Blister' THEN 'Other'
		WHEN B.Injury_Surgery = 'Blisters' THEN 'Other'
		WHEN B.Injury_Surgery = 'Bruised lung' THEN 'Other'
		WHEN B.Injury_Surgery = 'Elbow soreness / Strained hamstring' THEN 'Other'
		WHEN B.Injury_Surgery = 'Elbow/back soreness' THEN 'Other'
		WHEN B.Injury_Surgery = 'Gastroenteritis' THEN 'Other'
		WHEN B.Injury_Surgery = 'Hodgkin''s Lymphoma' THEN 'Other'
		WHEN B.Injury_Surgery = 'Irregular heartbeat' THEN 'Other'
		WHEN B.Injury_Surgery = 'Kidney ailment' THEN 'Other'
		WHEN B.Injury_Surgery = 'Kidney stones' THEN 'Other'
		WHEN B.Injury_Surgery = 'Mental health' THEN 'Other'
		WHEN B.Injury_Surgery = 'Non-Hodgkin''s Lymphoma' THEN 'Other'
		WHEN B.Injury_Surgery = 'Raynaud''s syndrome surgery' THEN 'Other'
		WHEN B.Injury_Surgery = 'TBD' THEN 'Other'
		WHEN B.Injury_Surgery = 'Ulcerative colitis' THEN 'Other'
		WHEN B.Injury_Surgery = 'Undisclosed' THEN 'Other'
		WHEN B.Injury_Surgery = 'Undisclosed medical condition' THEN 'Other'
		WHEN B.Injury_Surgery = 'AC joint inflammation' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Arthroscopic shoulder surgery' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Arthroscopic shoulder surgery (posterior labrum)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Flexor tendon surgery/Shoulder soreness' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Posterior shoulder discomfort' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Rotator cuff inflammation' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Rotator cuff tendinitis' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder bursitis' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder contusion' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder discomfort' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder discomfort (scapular stress fracture)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder dislocation (non-throwing)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder fatigue' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder impingement' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder impingement syndrome' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder inflammation' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder inflammation (scapula)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder inflammation (SI joint)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder nerve inflammation' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder nerve irritation' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder soreness' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder soreness (frayed labrum)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder subluxation (non-throwing)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (aneurysm)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (anterior capsule repair)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (cyst removal)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (glenohumeral ligaments and capsu' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (labral debridement)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (labrum debridement)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (labrum/rotator cuff cleanup)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (labrum/rotator cuff repair)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (torn capsule)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder surgery (torn labrum)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder tendinitis' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder tendinitis (rotator cuff)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder tendinopathy' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder tendonitis (rotator cuff)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Shoulder tightness' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Sprained shoulder' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained lat/Torn shoulder capsule' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained rotator cuff' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained shoulder' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained shoulder (capsular tear)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained shoulder (deltoid)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained shoulder (posterior capsule)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained shoulder (rotator cuff)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained shoulder (teres major)' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Strained teres major' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Stress fracture -- shoulder' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Stress reaction -- shoulder' THEN 'Shoulder'
		WHEN B.Injury_Surgery = 'Abscess removal procedure (thigh)' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Glute soreness' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Hamstring surgery' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Hamstring tendinitis' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Hamstring tendonitis' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Strained adductor' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Strained glute' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Strained hamstring' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Strained quad' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Thigh inflammation' THEN 'Thigh'
		WHEN B.Injury_Surgery = 'Biceps contusion' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Biceps discomfort' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Biceps inflammation' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Biceps nerve injury' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Biceps tendinitis' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Biceps tendon inflammation' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Biceps tendonitis' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Biceps tightness' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Strained biceps' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Strained triceps' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Triceps discomfort' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Triceps inflammation' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Triceps soreness' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Triceps tendinitis' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Triceps tightness' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Vascular surgery (upper arm aneurysm)' THEN 'Upper Arm'
		WHEN B.Injury_Surgery = 'Abdominal discomfort' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Abdominal surgery' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Bone graft surgery (rib)' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Chest contusion' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Fractured rib' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Intercostal irritation' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Oblique soreness' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Pectoral tightness' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Rib costochondritis' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Side discomfort' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Side tightness' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Sprained ribcage' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Sprained SC joint' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Strained abdominal' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Strained intercostal' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Strained oblique' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Strained pectoral' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Strained rib cage' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Stress fracture -- rib cage' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Stress reaction -- ribs' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Thoracic outlet syndrome' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Thoracic outlet syndrome surgery' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Thoracic outlet syndrome surgery (follow-up proced' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Thoracic spine inflammation' THEN 'Upper Body'
		WHEN B.Injury_Surgery = 'Thoracic spine tightness' THEN 'Upper Body'
		END AS Injury_Location
	into #PrePostInjury
	from #STEP10 a
	left join #InjuryMaster b
	on a.player_name=b.pitchdata_player_name
	and a.IL_Retro_Date=b.IL_Retro_Date;