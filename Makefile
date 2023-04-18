run:
	./get_resumes.sh | parallel -j '200%' --files ./parse_resume.sh | xargs -n 20 cat > res.csv
	python3 fixds.py -i res.csv -o res.json
	./get_reps.sh res.json > tmp.json
	./parse_reps.sh tmp.json
	rm res.csv
	rm res.json 
	mv tmp.json res.json
