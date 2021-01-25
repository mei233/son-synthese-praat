
clearinfo
#### la creation de la boite de dialoque #####

form la boite de dialoque
	comment choisissez la phrase :
	comment 1 : le temps passe tes tribunes changent mais pour toujours les souvenirs restent
	comment 2 : le temps passe tes visages changent mais pour toujours l'amour restent 
	comment 3 : le temps passe les gens changent mais pour toujours les classiques restent
	comment 4 : le temps passe la mode changent mais pour toujours les souvenirs restent
	choice votreChoix
		button phrase1
		button phrase2
		button phrase3
		button phrase4
endform

if votreChoix=1
	sequence$="le temps passe tes tribunes changent mais pour toujours les souvenirs restent"
elsif votreChoix=2
	sequence$="le temps passe tes visages changent mais pour toujours lamour restent"
elsif votreChoix=3
	sequence$="le temps passe les gens changent mais pour toujours les classiques restent"
else
	sequence$="le temps passe la mode changent mais pour toujours les souvenirs restent"
endif

dic = Read Table from tab-separated file: "dico.txt"
phrase_phonetique$ = ""

repeat
	espace = index(sequence$, " ")	
	if espace != 0
		permier_mot$ = left$(sequence$, espace-1)
		rest = length(sequence$)-espace
		sequence$ = right$(sequence$, rest)
	else 
		permier_mot$ = sequence$
	endif
	#pause le mot est: 'permier_mot$'
	select 'dic'
	extractPhone = Extract rows where column (text): "orthographe", "is equal to", permier_mot$
	mot_phonetique$ = Get value: 1, "phonetique"
	phrase_phonetique$ = phrase_phonetique$ + mot_phonetique$
	
until espace = 0

phrase_phonetique$ = "-" + phrase_phonetique$ + "-"
pause 'phrase_phonetique$'
pause Fini pour la phrase phonetique !


##### la synthese de la phrase ######

@getSound: phrase_phonetique$

procedure getSound: mot$
	#sound_synthese = Create Sound from formula: "son_synthese", 1, 0, 0.01, 44100, "0"
	sound_conca = Create Sound from formula: "son_synthese", 1, 0, 0.01, 44100, "0"
	text = Read from file: "texte.TextGrid"
	son = Read from file: "sons.wav"
	intersectionTotal = To PointProcess (zeroes): 1, "no", "yes"
	length_mot = length(mot$)

	for y from 1 to length_mot-1
		select 'text'
		mid_mot4$ = mid$(mot$, y, 2)
		left_diph$ = mid$(mid_mot4$,1, 1)
		right_diph$ = mid$(mid_mot4$,2, 1)

		nombreDIntervals = Get number of intervals: 1

		for x from 1 to nombreDIntervals-1
			select 'text' 
			label1$ = Get label of interval: 1, x
			label2$ = Get label of interval: 1, x+1

			if label1$ = left_diph$ and label2$ = right_diph$
				timeStart = Get start time of interval: 1, x
				timeStart2 = Get start time of interval: 1, x+1
				timeEnd = Get end time of interval: 1, x+1
				milieuStart = (timeStart + timeStart2)/2
				milieuEnd = (timeStart2 + timeEnd)/2  

				#pause printline 'left_diph$'..'right_diph$'
				#pause printline 'milieuStart'..'milieuEnd'
			
				select 'intersectionTotal'

				getindexStart = Get nearest index: milieuStart

				milieuStart = Get time from index: getindexStart

	
				getIndexEnd = Get nearest index: milieuEnd
				milieuEnd = Get time from index: getIndexEnd 
			
		
				select 'son'
				extrait_sons = Extract part: milieuStart, milieuEnd, "rectangular", 1, "no"

				select 'extrait_sons'
				plus 'sound_conca'
				sound_conca = Concatenate
		
			endif
		endfor
	endfor
	select 'sound_conca'
	Save as WAV file: "son_synthese.wav"
endproc

pause Fini pour la partie de synthese!


##### la modification de la phrase #######

modifi = Read from file: "son_synthese.wav"
#modification = sound_conca
fichier_modification = To Manipulation: 0.01, 75, 600
pitch_tier = Extract pitch tier
Shift frequencies: 0, 1000, 20, "Hertz"

select 'fichier_modification'
plus 'pitch_tier'
Replace pitch tier

select 'fichier_modification'
duration_tier = Extract duration tier

#pour la duration
select 'fichier_modification'
duration_tier = Extract duration tier
Remove points between: 0, 40
Add point: 0.5, 0.9

select 'fichier_modification'
plus 'duration_tier'
Replace duration tier

select 'fichier_modification'
resultat = Get resynthesis (overlap-add)

select 'resultat'
Save as WAV file: "son_synthese_modification.wav"

select all
minus 'modifi'
minus 'resultat' 
Remove



