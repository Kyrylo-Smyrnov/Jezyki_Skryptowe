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

print() {
    echo "| ${field[11]} | ${field[12]} | ${field[13]} |"
    echo " "
    echo "| ${field[21]} | ${field[22]} | ${field[23]} |"
    echo " "
    echo "| ${field[31]} | ${field[32]} | ${field[33]} |"
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
            echo
            print
            echo "Winner: $elem1 !"
            exit 0
        fi
    done
}

check_draw() {
    for elem in "${!field[@]}"; do
        if [ "${field[$elem]}" = " " ]; then
            return
        fi
    done

    echo
    print
    echo "Draw!"
    exit 0
}

isCrossTurn=1

while true; do
    symbol=" "
    if [ $isCrossTurn -eq 1 ]; then
        symbol="X"
        isCrossTurn=0
    else
        symbol="0"
        isCrossTurn=1
    fi

    print
    echo " "
    read -p "Enter your turn [row][column]: " turn
    if [[ -v field[$turn] ]]; then
        field[$turn]=$symbol
        check_winner
        check_draw
    else
        echo " "
        echo "Incorrect input"
        echo " "
    fi
done