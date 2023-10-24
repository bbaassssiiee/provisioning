# make a local environment and use molecule test

../base:
	python3 -m venv ../base
	(source ../base/bin/activate && python3 -m pip install --upgrade pip)
	(source ../base/bin/activate && pip3 install -r requirements.txt)
	(source ../base/bin/activate && molecule test)
	(source ../base/bin/activate && pre-commit install)
	(source ../base/bin/activate && pre-commit run --all-files)


clean:
	rm -rf ../base
