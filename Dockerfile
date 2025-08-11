#Using Python Image to create docker container image
FROM python:3.11-slim

#Working Directory
WORKDIR /app

#copy files
COPY . /app/

#Installing dependancies
RUN pip install flask

#Exposing application on tcp port
EXPOSE 5000

#Run the app using commands
CMD [ "python", "app.py" ]