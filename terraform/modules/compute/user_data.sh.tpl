#!/bin/bash
# Runtime configuration script for application instances
# This script runs on first boot to configure database connection

set -e

# Extract hostname from endpoint (remove :port)
DB_HOST=$(echo "${db_host}" | cut -d: -f1)
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"

# Wait for network to be ready
sleep 10

# Create database.php with runtime configuration
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
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SHOW TABLES;" > /dev/null 2>&1
if [ $? -ne 0 ] || [ $(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SHOW TABLES;" 2>/dev/null | wc -l) -lt 2 ]; then
    echo "Initializing database schema..." >> /var/log/user-data.log
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < /var/www/html/create_database.sql 2>&1 | tee -a /var/log/user-data.log || true
fi

# Log success
echo "Database configuration created successfully at $(date)" >> /var/log/user-data.log
echo "DB_HOST: $DB_HOST, DB_USER: $DB_USER, DB_NAME: $DB_NAME" >> /var/log/user-data.log
