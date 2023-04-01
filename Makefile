run:
	./get_resumes.sh | xargs -n1 ./parse_resume.sh > res.csv
