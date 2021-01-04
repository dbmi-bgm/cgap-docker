build:
	docker build -t cgap-ingestion-docker:0.0.0b0 .

enter:
	docker run -it cgap-ingestion-docker:0.0.0b0 bash
