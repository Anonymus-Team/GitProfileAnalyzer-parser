run:
	./get_resumes.sh | xargs -n1 ./parse_resume.sh > res.csv
	python3 fixds.py -i res.csv -o res.json
	./get_reps.sh res.json > tmp.json
	./parse_reps.sh tmp.json
	rm res.csv
	rm res.json 
	mv tmp.json res.json
