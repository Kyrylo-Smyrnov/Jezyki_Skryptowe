declare -A field

field[11]=" "
field[12]=" "
field[13]=" "
field[21]=" "
field[22]=" "
field[23]=" "
field[31]=" "
field[32]=" "
field[33]=" "
isCrossTurn=""

clear_board() {
    field[11]=" "
    field[12]=" "
    field[13]=" "
    field[21]=" "
    field[22]=" "
    field[23]=" "
    field[31]=" "
    field[32]=" "
    field[33]=" "
    isCrossTurn=""
}

print() {
    echo "+---+---+---+"
    echo "| ${field[11]} | ${field[12]} | ${field[13]} |"
    echo "+---+---+---+"
    echo "| ${field[21]} | ${field[22]} | ${field[23]} |"
    echo "+---+---+---+"
    echo "| ${field[31]} | ${field[32]} | ${field[33]} |"
    echo "+---+---+---+"
}

check_winner() {
    local win_conditions=(
        "11 12 13"
        "21 22 23"
        "31 32 33"
        "11 21 31"
        "12 22 32"
        "13 23 33"
        "11 22 33"
        "13 22 31"
    )

    for win_condition in "${win_conditions[@]}"; do
        read a b c <<< "$win_condition"
        elem1="${field[$a]}"
        elem2="${field[$b]}"
        elem3="${field[$c]}"

        if [ "$elem1" != " " ] && [ "$elem1" = "$elem2" ] && [ "$elem2" = "$elem3" ]; then
            clear
            print
            echo " "
            echo "---Winner: $elem1!---"
            echo " "
            read -p "Press any button to back to main menu"
            main_menu
        fi
    done
}

check_draw() {
    for elem in "${!field[@]}"; do
        if [ "${field[$elem]}" = " " ]; then
            return
        fi
    done

    clear
    print
    echo " "
    echo "---Draw!---"
    echo " "
    read -p "Press any button to back to main menu"
    main_menu
}

play_vs_player() {
    while true; do
        symbol=" "
        if [ $isCrossTurn -eq 1 ]; then
            symbol="X"
            isCrossTurn=0
        else
            symbol="O"
            isCrossTurn=1
        fi

        clear
        print
        echo " "
        echo "Enter \"save\" to save the game."
        read -p "Enter your turn [row][column] ($symbol): " turn

        if [[ "$turn" == "save" ]]; then
            read -p "Enter file name: " file
            save_game $file
        fi

        if [[ -v field[$turn] ]] && [[ "${field[$turn]}" == " " ]]; then
            field[$turn]=$symbol
            check_winner
            check_draw
            continue
        fi

        if [ $isCrossTurn -eq 1 ]; then
            isCrossTurn=0
        else
            isCrossTurn=1
        fi
    done
}

play_vs_computer() {
    local user_symbol="O"
    local comp_symbol="X"

    while true; do
        clear
        print
        echo " "
        read -p "Enter your turn [row][column] ($user_symbol): " turn

        if [[ -v field[$turn] ]] && [[ "${field[$turn]}" == " " ]]; then
            field[$turn]=$user_symbol
            check_winner
            check_draw
        else
            continue
        fi

        for key in "${!field[@]}"; do
            if [[ "${field[$key]}" == " " ]]; then
                field[$key]=$comp_symbol
                check_winner
                check_draw
                break
            fi
        done
    done
}

save_game() {
    local filename=$1
    if [[ $isCrossTurn -eq 1 ]]; then
        echo "0" > $filename
    else
        echo "1" > $filename
    fi
    for key in "${!field[@]}"; do
        echo "$key ${field[$key]}" >> "$filename"
    done

    main_menu
}

load_game() {
    local filename=$1

    clear_board

    while IFS= read -r line || [ -n "$line" ]; do
        if [ -z "$isCrossTurn" ]; then
            isCrossTurn="$line"
            continue
        fi

        key=$(echo "$line" | awk '{print $1}')
        value=$(echo "$line" | awk '{print $2}')
        if [[ "$value" == "X" ]] || [[ "$value" == "O" ]]; then
            field["$key"]="$value"
        fi
    done < "$filename"
    
    play_vs_player
}

main_menu(){
    clear
    echo " ---Tic-Tac-Toe---"

while true; do
    echo " "
    echo "1 | Play vs player"
    echo "2 | Play vs computer"
    echo "3 | Load game"
    echo " "
    read -p "Chose action: " choose
    if [ "$choose" -eq 1 ]; then
        clear_board
        play_vs_player
    fi
    if [ "$choose" -eq 2 ]; then
        clear_board
        play_vs_computer
    fi
    if [ "$choose" -eq 3 ]; then
        echo " "
        read -p "Enter file name: " file
        if [ -f "$file" ]; then
            load_game "$file"
        else
            echo "Invalid file name"
        fi
    fi
done
}

main_menu