#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  # If get back to main menu
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  # show services
  ALL_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$ALL_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME 
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # echo "999) EXIT"
  # read input
  read SERVICE_ID_SELECTED
  # if not number
  # if [[ ! $SERVICE_ID_SELECTED =~ ^([0-9]+)$ ]]
  # then
  #   MAIN_MENU "Please select the services number on lists."
  # fi
  # Exit Program
  # if [[ $SERVICE_ID_SELECTED = 999 ]]
  # then
  #   EXIT
  # fi
  # find service id
  INPUT_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if not found service id
  if [[ -z $INPUT_SERVICE_ID ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # found serivce id
    # get service name
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $INPUT_SERVICE_ID")
    # ask for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # find customer name from phone
    GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if not found customer name
    if [[ -z $GET_CUSTOMER_NAME ]]
    then
      # ask for register name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # register name and phone to database
      INSERT_RESULT=$($PSQL "INSERT INTO customers (name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      # get new customer_name
      GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'") 
    # ask time for service
    echo -e "\nWhat time would you like your $(echo $SERVICE | sed -E 's/^ *| *$//g'), $(echo $GET_CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
    read SERVICE_TIME
    # register appoinment time
    INSERT_APPOINMENT_RESULT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME',$CUSTOMER_ID,$INPUT_SERVICE_ID)")
    # confirm appoinment time
    if [[ $INSERT_APPOINMENT_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\nI have put you down for a$SERVICE at $SERVICE_TIME,$GET_CUSTOMER_NAME.\n"
    fi
  fi
}

# EXIT(){
#   echo -e "\nThank you for stopping in.\n"
#   exit 1
# }

MAIN_MENU