#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # 1. Display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # 2. Format the list as #) <service>
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # 3. Read service selection
  read SERVICE_ID_SELECTED

  # 4. Check if service exists
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # If not found, show menu again
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # 5. Get customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # 6. Check if customer exists
    if [[ -z $CUSTOMER_NAME ]]
    then
      # New customer: Get name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # 7. Get appointment time
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed 's/ //g')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //g')
    
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

    # 8. Get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # 9. Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # 10. Output final message
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

MAIN_MENU
