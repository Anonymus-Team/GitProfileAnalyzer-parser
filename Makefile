run:
	./get_resumes.sh | xargs -n1 ./parse_resume.sh > res.json
	./get_reps.sh res.json > tmp.json
	rm res.json 
	mv tmp.json res.json
