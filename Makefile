run:
	./get_resumes.sh | xargs -n1 ./parse_resume.sh > res.csv
	python3 fixds.py -i res.csv 
	rm res.csv
	mv out.csv res.csv
