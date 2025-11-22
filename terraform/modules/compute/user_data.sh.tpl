#!/bin/bash
# Runtime configuration script for application instances
# This script runs on first boot to configure database connection

# Enable logging to a file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user_data script execution at $(date)"

# Extract hostname from endpoint (remove :port)
DB_HOST=$(echo "${db_host}" | cut -d: -f1)
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"

echo "Configuration extracted:"
echo "DB_HOST: $DB_HOST"
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"

# Wait for network and database to be ready
echo "Waiting for database connection..."
MAX_RETRIES=30
COUNT=0
while ! mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; do
    sleep 5
    COUNT=$((COUNT+1))
    if [ $COUNT -ge $MAX_RETRIES ]; then
        echo "Timeout waiting for database connection"
        exit 1
    fi
    echo "Waiting for DB... ($COUNT/$MAX_RETRIES)"
done
echo "Database connection established."

# Create database.php with runtime configuration
echo "Generating database.php..."
cat > /var/www/html/database.php <<PHPEOF
<!DOCTYPE html>
<html>
<head>
    <style type="text/css" media="screen">
        input.largerCheckbox { 
            width: 20px; 
            height: 20px; 
        } 
    </style>
</head>
</html>

<?php
    session_start();
    if(isset(\$_POST['Delete']))
    {
        if(!empty(\$_POST['check_list']))
        {
            \$tasks = \$_POST['check_list'];
            \$length = count(\$tasks);
            for (\$i = 0; \$i < \$length; \$i++) {
                deleteTodoItem(\$_SESSION['username'], \$tasks[\$i]);
            }
        }
    }
    else if(isset(\$_POST['Save']))
    {
        \$conn = connectdatabase();
        \$sql = "UPDATE $DB_NAME.tasks SET done = 0";
        \$result = mysqli_query(\$conn, \$sql); 
        mysqli_close(\$conn);

        if(!empty(\$_POST['check_list']))
        {
            \$tasks = \$_POST['check_list'];
            \$length = count(\$tasks);
            if(\$length > 0) {
                for (\$i = 0; \$i < \$length; \$i++) {
                    updateDone(\$tasks[\$i]);
                }
            }
        }
    }

    function connectdatabase() {
        return mysqli_connect("$DB_HOST", "$DB_USER", "$DB_PASSWORD", "$DB_NAME");
    }

    function loggedin() {
        return isset(\$_SESSION['username']);
    }

    function logout() {
        \$_SESSION['error'] = "&nbsp; Succesfully logout !!";
        unset(\$_SESSION['username']);
    }

    function spaces(\$n) {
        for(\$i=0; \$i<\$n; \$i++)
            echo "&nbsp;";
    }

    function userexist(\$username) 
    {
        \$conn = connectdatabase();
        \$sql = "SELECT * FROM $DB_NAME.users WHERE username = '".\$username."'"; 
        \$result = mysqli_query(\$conn,\$sql);
        mysqli_close(\$conn);

        if(!\$result || mysqli_num_rows(\$result) == 0) { 
           return false;
        }
        return true;
    }

    function validuser(\$username, \$password) 
    {
        \$conn = connectdatabase();
        \$sql = "SELECT * FROM $DB_NAME.users WHERE username = '".\$username."'AND password = '".\$password."'"; 
        \$result = mysqli_query(\$conn,\$sql);
        mysqli_close(\$conn);

        if(!\$result || mysqli_num_rows(\$result) == 0) { 
           return false;
        }
        return true;
    }

    function error() 
    {
        if(isset(\$_SESSION['error'])) {
            echo \$_SESSION['error'];
            unset(\$_SESSION['error']);
        }
    }

    function updatepassword(\$username, \$password) {
        \$conn = connectdatabase();
        \$sql = "UPDATE $DB_NAME.users SET password = '".\$password."' WHERE username = '".\$username."';";
        \$result = mysqli_query(\$conn, \$sql);

        \$_SESSION['error'] = "<br> &nbsp; Password Updated !! ";
        header('location:todo.php');
    }

    function deleteaccount(\$username) {
        \$conn = connectdatabase();
        \$sql = "DELETE FROM $DB_NAME.tasks WHERE username = '".\$username."';";
        \$result = mysqli_query(\$conn, \$sql);

        \$sql = "DELETE FROM $DB_NAME.users WHERE username = '".\$username."';";
        \$result = mysqli_query(\$conn, \$sql);

        \$_SESSION['error'] = "&nbsp; Account Deleted !! ";
        unset(\$_SESSION['username']);
        header('location:login.php');
    }

    function createUser(\$username, \$password)
    {
        if(!userexist(\$username))
        {
            \$conn = connectdatabase();
            \$sql = "INSERT INTO $DB_NAME.users (username, password) VALUES ('".\$username."','".\$password."')";
            \$result = mysqli_query(\$conn, \$sql);

            \$_SESSION["username"] = \$username;
            header('location:todo.php');
        }
        else
        {
            \$_SESSION['error'] = "&nbsp; Username already exists !! ";
            header('location:newuser.php');
        }
    }
    
    function isValid(\$username, \$password, \$usercaptcha)
    {
        \$capcode = \$_SESSION['captcha'];

        if(!strcmp(\$usercaptcha,\$capcode))
        {
            if(validuser(\$username, \$password))
            {
                \$_SESSION["username"] = \$username;
                header('location:todo.php');
            }
            else
            {
                \$_SESSION['error'] = "&nbsp; Invalid Username or Password !! ";
                header('location:login.php');
            }
        }
        else
        {
            \$_SESSION['error'] = "&nbsp; Invalid captcha code !! ";
            header('location:login.php');
        }
    }
    
    function getTodoItems(\$username) {

        \$conn = connectdatabase();
        \$sql = "SELECT * FROM tasks WHERE username = '".\$username."'";
        
        \$result = mysqli_query(\$conn, \$sql);

        echo "<form method='POST'>";
        echo "<pre>";
        if (\$result and mysqli_num_rows(\$result) > 0) {
            while(\$row = mysqli_fetch_assoc(\$result)) {

                spaces(15);
                if(\$row['done']) {
                    echo "<input type='checkbox' checked class='largerCheckbox' name='check_list[]' value='".\$row["taskid"] ."'>";
                }
                else {
                    echo "<input type='checkbox' class='largerCheckbox' name='check_list[]' value='".\$row["taskid"] ."'>";
                }
                echo "<td> " . \$row["task"] . "</td>";
                echo "<br>";
            }
        }
        echo "</pre> <hr>";
        spaces(35);
        echo "<input type='submit' name='Delete' value='Delete'/>";
        spaces(10);
        echo "<input type='submit' name='Save' value='Save'/>";
        echo "</form>";
        echo "<br><br>";
        mysqli_close(\$conn);
    }

    function addTodoItem(\$username, \$todo_text) 
    {
        \$conn = connectdatabase();
        \$sql = "INSERT INTO $DB_NAME.tasks(username, task, done) VALUES ('".\$username."','".\$todo_text."',0);";
        \$result = mysqli_query(\$conn, \$sql);
        mysqli_close(\$conn);
    }
    
    function deleteTodoItem(\$username, \$todo_id) 
    {
        \$conn = connectdatabase();
        \$sql = "DELETE FROM $DB_NAME.tasks WHERE taskid = ".\$todo_id." and username = '".\$username."';";
        \$result = mysqli_query(\$conn, \$sql);
        mysqli_close(\$conn);
    }

    function updateDone(\$todo_id) 
    {
        \$conn = connectdatabase();
        \$sql = "UPDATE $DB_NAME.tasks SET done = '1' WHERE (taskid = '".\$todo_id."');";
        \$result = mysqli_query(\$conn, \$sql);   
        mysqli_close(\$conn);
    }
?>
PHPEOF

# Set proper permissions
chown www-data:www-data /var/www/html/database.php
chmod 644 /var/www/html/database.php

# Initialize database schema if tables don't exist
echo "Checking database schema..."
# Check if users table exists
TABLE_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SHOW TABLES LIKE 'users';" 2>/dev/null | wc -l)

if [ "$TABLE_COUNT" -eq 0 ]; then
    echo "Initializing database schema..."
    # Remove CREATE DATABASE statement as DB already exists (managed by Terraform)
    sed -i '/CREATE DATABASE/d' /var/www/html/create_database.sql
    sed -i '/USE todo/d' /var/www/html/create_database.sql
    
    # Import schema
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < /var/www/html/create_database.sql
    echo "Schema initialized."
else
    echo "Database already initialized."
fi

echo "User data script completed successfully at $(date)"
