### Check all settings work

Ultra Player Frame

- When turned off, we still see combo points when playing rogue/feral druid.

Pops problem
Party frames move so you are unable to see ! !! and !!!
Happened when playing as a healer, in Deadmines, and doing some dps

Verification Tab

Record per level verification process.
For each level the character has gained thus far, we should have verification for each.
The check:
XP gained vs XP in level.
I.e: level 3 has 1,400 xp in it. We record the XP gained for the level. If XP gained this level is equal to, with 10% leniency, we pass the check. This means the player can complete a level with only 1260 (90%) recorded xp and still pass the check.

We should have a panel at the top of the tab showing the summary of the verification.
We should have a decription below, which provides details on verification, which I'll fill in later.

We should fill the rest of the tab with a scrollable table which will show each level.
Each level has a horizontal bar chart, filled to the % of recorded xp. for that level. Including the current one.

The current level should fill in the missing xp with blue, i.e: if the max xp for the current level is 100, and we have recorded 50 but the total xp this level is 80, 50% should be green, 30% blue, the rest blank.

If our addon recorded xp is within 90% of the real xp gained, the bar of each level should be green.
If between 70-90%, orange.
Any less than this should be red.

Below is the correct XP per level table, which we should use for verification.
| Tier | Lvl | Max XP |
|------|-----|--------|
| 1–20 | 1 | 400 |
| 1–20 | 2 | 900 |
| 1–20 | 3 | 1,400 |
| 1–20 | 4 | 2,100 |
| 1–20 | 5 | 2,800 |
| 1–20 | 6 | 3,600 |
| 1–20 | 7 | 4,500 |
| 1–20 | 8 | 5,400 |
| 1–20 | 9 | 6,500 |
| 1–20 | 10 | 7,600 |
| 1–20 | 11 | 8,800 |
| 1–20 | 12 | 10,100 |
| 1–20 | 13 | 11,400 |
| 1–20 | 14 | 12,900 |
| 1–20 | 15 | 14,400 |
| 1–20 | 16 | 16,000 |
| 1–20 | 17 | 17,700 |
| 1–20 | 18 | 19,400 |
| 1–20 | 19 | 21,300 |
| 1–20 | 20 | 23,200 |
| 21–40 | 21 | 25,200 |
| 21–40 | 22 | 27,300 |
| 21–40 | 23 | 29,400 |
| 21–40 | 24 | 31,700 |
| 21–40 | 25 | 34,000 |
| 21–40 | 26 | 36,400 |
| 21–40 | 27 | 38,900 |
| 21–40 | 28 | 41,400 |
| 21–40 | 29 | 44,300 |
| 21–40 | 30 | 47,400 |
| 21–40 | 31 | 50,800 |
| 21–40 | 32 | 54,500 |
| 21–40 | 33 | 58,600 |
| 21–40 | 34 | 62,800 |
| 21–40 | 35 | 67,100 |
| 21–40 | 36 | 71,600 |
| 21–40 | 37 | 76,100 |
| 21–40 | 38 | 80,800 |
| 21–40 | 39 | 85,700 |
| 21–40 | 40 | 90,700 |
| 41–60 | 41 | 95,800 |
| 41–60 | 42 | 101,000 |
| 41–60 | 43 | 106,300 |
| 41–60 | 44 | 111,800 |
| 41–60 | 45 | 117,500 |
| 41–60 | 46 | 123,200 |
| 41–60 | 47 | 129,100 |
| 41–60 | 48 | 135,100 |
| 41–60 | 49 | 141,200 |
| 41–60 | 50 | 147,500 |
| 41–60 | 51 | 153,900 |
| 41–60 | 52 | 160,400 |
| 41–60 | 53 | 167,100 |
| 41–60 | 54 | 173,900 |
| 41–60 | 55 | 180,800 |
| 41–60 | 56 | 187,900 |
| 41–60 | 57 | 195,000 |
| 41–60 | 58 | 202,300 |
| 41–60 | 59 | 209,800 |
| 41–60 | 60 | 217,400 |


## Verification 60s

Send addon messages to uhc chat channel if lvl 60 and verified and not backdated
Send every 5 minutes?
Only I will listen and create a list of player names and the settings tier