#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~ Welcome to my salon! ~~\n"

MAIN_MENU(){
  if [[ $1 ]]; then
    echo -e $1
  fi
  echo -e "Choose service to make an appointment\n"
  echo -e "0) exit"

  # get service list and display all services
  SERVICE_LIST="$($PSQL "SELECT service_id, name FROM services;")"
  echo -e "$SERVICE_LIST" | while read ID BAR NAME
  do
    echo -e "$ID) $NAME"
  done
  echo -e "\n"
  # get service id
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "Please enter a number.\nReturn to the main menu."
  
  else
    # if input = 0, exit
    if [[ $SERVICE_ID_SELECTED -eq 0 ]]; then
      echo "Thank you for visiting us!"
      exit 0

    else
      # get the name of the service chosen
      SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
      
      # check the service exists
      if [[ -z $SERVICE_NAME ]]; then
        # if the service doesn't exist, return to main menu
        MAIN_MENU "Please enter a service number that is available."
      
      else
        echo -e "\nWe will Register the ($SERVICE_ID_SELECTED)$SERVICE_NAME appointment."
        
        # get customer's phone number
        echo -e "Please enter your phone number.\n"
        read CUSTOMER_PHONE
        
        # search customer's id
        CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
        
        # if customer is not registered
        if [[ -z $CUSTOMER_ID ]]; then

          # get customer's name from input
          echo -e "\nWe will register you to database.\nPlease enter your name.\n"
          read CUSTOMER_NAME

          # register customer to the database 
          INSERT_INTO_CUSTOMERS_RESULT="$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
          if [[ $INSERT_INTO_CUSTOMERS_RESULT == 'INSERT 0 1' ]]; then
            echo -e "\nYou were successfully registered to our database."
            CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
          else
            echo -e "\nIt seems something went wrong. We are sorry, but please try again.\n"
            exit 1
          fi
        fi

        # get appointment's time
        echo -e "\nPlease enter the appointment time."
        read SERVICE_TIME

        # register an appointment
        INSERT_INTO_APPOINTMENTS="$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"
        if [[ $INSERT_INTO_APPOINTMENTS == 'INSERT 0 1' ]]; then
          echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        else
          echo -e "\nIt seems something went wrong. We are sorry, but please try again.\n"
          exit 1 
        fi
      fi
    fi
  fi

}

MAIN_MENU