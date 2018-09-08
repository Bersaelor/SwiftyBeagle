docker stop $(docker ps -aqf "ancestor=swiftybeagle") &> /dev/null && docker rm $(docker ps -aqf "ancestor=swiftybeagle") &> /dev/null
docker build -t swiftybeagle . &&
docker run -d -p 8080:8080 swiftybeagle 
docker attach $(docker ps -aqf "ancestor=swiftybeagle")
