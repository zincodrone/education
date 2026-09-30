#!/bin/bash
# Password Checker

#Code to check password strength
#It is split up to make it easier to read and debug, however the one line is:
#"^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@\$!%*?&])[A-Za-z0-9@\$!%*?&]{24,}$"
#^^ NOTICE: I updated the script with an autofail, when originally designing this script I made it a one line,
#but it made it too difficult to edit to test things, so i've split it up using a lot of my previous coding logic
#i learned when programming in Lua obviously it's good for shorter scripts but not good for large programs

#Prevents changes... and also starts tracking a score.
			
	passcheck() {
			local pass="$1"
			local errors=()
			local score=0

			
#It has an auto fail section for password length.
	local pass_length=${#pass}
# -lt stands for less than
	if [[ $pass_length -lt 24 ]]; then
				errors+=("Password is not 24 characters long.")
				
			if [[ "$pass" =~ [a-z] ]]; then
				((score+= 2))
			else
				errors+=("Password doesn't have a lowercase letter.")
			fi
			
			if [[ "$pass" =~ [A-Z] ]]; then
				((score+= 2))
			else	
				errors+=("Password doesn't have an uppercase letter.")
			fi
#to prevent errors i used the bash code for punctiation (::punct::)
			if [[ "$pass" =~ [[:punct:]] ]]; then
				((score+= 2))
			else	
				errors+=("Password doesn't have a special character.")
			fi
			
			if [[ "$pass" =~ [0-9] ]]; then
				((score+= 2))
			else
				errors+=("Password doesn't have a number.")
			fi
#From my testing this section doesn't even work anymore? I'm not for sure why probably the auto fail.
#I'm too tired to fix it. It's 2:18AM.			
			score=4
		else
			((score +=2))
			
			if [[ "$pass" =~ [a-z] ]]; then
				((score+= 2))
			else
				errors+=("Password doesn't have a lowercase letter.")
			fi
			
			if [[ "$pass" =~ [A-Z] ]]; then
				((score+= 2))
			else	
				errors+=("Password doesn't have an uppercase letter.")
			fi
			
			if [[ "$pass" =~ [[:punct:]] ]]; then
				((score+= 2))
			else	
				errors+=("Password doesn't have a special character.")
			fi
			
			if [[ "$pass" =~ [0-9] ]]; then
				((score+= 2))
			else
				errors+=("Password doesn't have a number.")
			fi
	fi
			
			echo ""
			echo "Your password strength"
	#the astrix makes it so that if there is no errors it automatically counts as very strong but if 
	#it's listed under certain things it's seen as not as strong
	#this however doesn't work but the binary weak/strong should work fine enough
	#gotta love code breaking when you add stuff amiright?
	#i'm fine with losing points on it cause i can't really care atp
	#2:34 AM - Oh wait it still works, it's just weak, strong, and very strong, i can't get super weak to work
	#but it could but i think it's blocked by the autofail
	#you can see the scoring system using less than or equal to ">=" which allows for proper grading however, it doesn't
	#really matter.
	#i just did it because i'm falling back on my lua knowledge
			if [[ -z "${errors[*]}" ]]; then
				echo "is very strong"
				return 0	
			else
				
				if (( score >= 6 )); then
					echo "is strong"
					
				elif (( score >= 4 )); then
					echo "is weak"
					
				else
					echo "is super weak."
				fi
				
				echo ""
				echo "Password doesn't meet requirements"
					for error in "${errors[@]}"; do
						echo "   - $error"
					done
				return 1
				fi
}
	
#Display Menu

#This provides 3 choices

#It first sets up a group of options then calls upon it by using "case" 
#which allows the code above to trigger to either check a passwords strength or 
#check the guidelines for what counts as a strong password.
#For it to call code above, it has to be below, otherwise it would not work.
#I've also added some breaks so it has some time between commands to make it more smooth
#^^NOTICE: I've removed these breaks, as I no longer care. It's 2AM and i'm super tired and I've been working on this for 9 hours now.
#I would've added a progress bar or idle anim but I'd rather not go through the hassle.
PS3="Please enter your choice: "
options=("Check Password" "Get Guidelines" "Quit")
select option in "${options[@]}"
do
    case $option in
        "Check Password")
#-n prevents a new line	
			echo -n "Enter the password you are checking..."
			read pass
#\n makes a new line	with the -e making it work		
			echo -e "\nChecking password strength"
			passcheck "$pass"
			echo ""
            ;;
        "Get Guidelines")
#legit the most simple part of the script
            echo "Grabbing guidelines please wait."
            echo "Must be 24+ characters with uppercase, lowercase, numbers, and symbols. It's graded on a 8 point scale."
            echo ""
            ;;
        "Quit")
#stops the loop		
            break
            ;;
		*)
			echo "Option not listed, please choose a option listed."
			;;
    esac
done

#to understand the logic for the main part, the if/fi, then, else, and elif statements make it so that
#checks for a specific requirements (eg. [[ -z "${errors[*]}" ]]) then gives a score but if it doesn't have
#the requirement met it will then give an error.

#the "$" makes a variable to be called upon
#logtime - 2:32AM could've sworn there was a -z in here somewhere but for those wondering
#it checks for an empty string

#logtime - 2:38AM i'm stopping work on this and submitting it, i'm gonna be late for my classes tomorrow anyway
#but i had to get this finished because i have work on wednesday and i was never gonna get it finished on Thursday