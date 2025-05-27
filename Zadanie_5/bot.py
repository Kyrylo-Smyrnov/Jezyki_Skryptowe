import discord
import requests
import json

# Trzeba uzupełnić token
DISCORD_TOKEN = ''

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

STATE = {}
DOTA_TOURNAMENT = []
DOTA_DATE = "10.10.2025"
CS_TOURNAMENT = []
CS_DATE = "09.09.2025"
LOL_TOURNAMENT = []
LOL_DATE = "08.08.2025"
SC2_TOURNAMENT = []
SC2_DATE = "07.07.2025"

async def sendMessageToDiscord(disMessage, msg):
    ping = disMessage.author.mention
    await disMessage.channel.send(f"{ping}\n{msg}")

def postRequestToAI(input):
    try:
        response = requests.post(
            'http://localhost:11434/api/generate',
            json={
                'model': 'llama3.2',
                'prompt': input,
                'stream': False
            }
        )

        data = response.json()
        reply = data.get('response', '').strip()

        if(reply):
            return reply

    except Exception as e:
        return None

def defineUserPurpose(input):
    # Model może domyślać grę do rejestracji nawet jeśli nie jest podana.
    # Wypróbowałem wiele róźnych promptów ale nadal ten sam problem, ten dziala lepiej od innych :(
    prompt = f"""
        You're the assistant to the cyber sports chat room.
        Your task is only to get the necessary data from the user input and return it in JSON format.
        Required data: what exactly the user wants to accomplish. The possible options are only these:
        1. User wants to register for a tournament for specific game ("register").
        2. User wants to know what tournaments are held ("list").
        3. User wants more information about the tournament for a specific game ("details"). Example: register teams, date of the tournament etc.
        Return ONLY JSON in this exact format:
        {{"purpose": "register" | "list" | "details", "game": "DOTA" | "CS" | "LOL" | "SC2" | null}}
        Rules:
        1. If purpose is "register" or "details", extract "game" ONLY if it is clearly mentioned in the message.
        2. DO NOT guess or infer the game. If the game is not clearly named, set "game" to null.
        3. If purpose cannot be determined, return null.
        No explanations, no comments, no text — only the JSON object or null.
        Given a user message: "{input}", determine the user's purpose and game if it's specified.
    """
    response = postRequestToAI(prompt)

    try:
        return json.loads(response)
    except json.JSONDecodeError as e:
        return None

async def handleUserRegistration(message, input, game):
    prompt = f"""
        You're the assistant to the cyber sports chat room.
        Your task is to get the name of the team or player who wants to register for the tournament.
        Return ONLY JSON in this exact format:
        {{"name": "..." | null}}
        Given a user message: "{input}", determine the user's team name / nickname.
    """

    if(message.content.startswith('/ai ')):
        input = message.content[len('/ai '):]

    response = postRequestToAI(prompt)
    try:
        jsonResp = json.loads(response)
    except json.JSONDecodeError:
        await sendMessageToDiscord(message, f"Model error, try one more time.")
        return

    if(jsonResp.get("name") is not None):
        if(game == "DOTA"):
            DOTA_TOURNAMENT.append(jsonResp.get("name"))
            msg = "You are registered for DOTA 2 tournament as " + jsonResp.get("name")
            msg += f"\nYou are {len(DOTA_TOURNAMENT)} team on the tournament."
        elif(game == "CS"):
            CS_TOURNAMENT.append(jsonResp.get("name"))
            msg = "You are registered for Counter Strike tournament as " + jsonResp.get("name")
            msg += f"\nYou are {len(CS_TOURNAMENT)} team on the tournament."
        elif(game == "LOL"):
            LOL_TOURNAMENT.append(jsonResp.get("name"))
            msg = "You are registered for League of Legends tournament as " + jsonResp.get("name")
            msg += f"\nYou are {len(LOL_TOURNAMENT)} team on the tournament."
        else:
            SC2_TOURNAMENT.append(jsonResp.get("name"))
            msg = "You are registered for Star Craft 2 tournament as " + jsonResp.get("name")
            msg += f"\nYou are {len(SC2_TOURNAMENT)} player on the tournament."

        await sendMessageToDiscord(message, msg)
    else:
        msg = "Try one more time, specify your team name / nickname inside your message."

async def handleList(message):
    msg = (
    "Our organization currently holds tournaments for the following games:\n"
    "- DOTA 2\n"
    "- Counter Strike\n"
    "- League of Legends\n"
    "- Star Craft 2")

    await sendMessageToDiscord(message, msg)

async def handleDetails(message, game):
    if(game == "DOTA"):
        teams = DOTA_TOURNAMENT
        date = DOTA_DATE
        player = "team(s)"
        name = "DOTA 2"
    elif(game == "CS"):
        teams = CS_TOURNAMENT
        date = CS_DATE
        player = "team(s)"
        name = "Counter Strike"
    elif(game == "LOL"):
        teams = LOL_TOURNAMENT
        date = LOL_DATE
        player = "team(s)"
        name = "League of Legends"
    else:
        teams = SC2_TOURNAMENT
        date = SC2_DATE
        player = "player(s)"
        name = "Star Craft 2"

    if(not teams):
        msg = f"{name} tournament is scheduled for {date}.\n"
        msg += f"No {player} are currently registered for the {name} tournament."
    else:
        msg = f"{name} tournament is scheduled for {date}.\n"
        msg += f"Currently registered {len(teams)} {player}.\n"
        msg += f"Teams registered for the {name} tournament:\n"
        msg += "\n".join(f"- {team}" for team in teams) + "\n"
        msg += "You can register for that tournament." if(len(teams) < 16) else "You cannot register for that tournament."

    await sendMessageToDiscord(message, msg)
    
@client.event
async def on_message(message):
    if(message.author.bot):
        return

    ID = str(message.author.id)

    if(ID in STATE):
        state = STATE.pop(ID)
        if(state["awaiting"] == "teamName"):
            await handleUserRegistration(message, message.content, state["game"])
        return

    if(message.content.startswith('/ai ')):
        input = message.content[len('/ai '):]
        purpose = defineUserPurpose(input)

        if(purpose is not None):
            if(purpose.get("purpose") == "register"):
                if(purpose.get("game") is not None):

                    if(purpose.get("game") == "DOTA" and len(DOTA_TOURNAMENT) >= 16 or
                    purpose.get("game") == "CS" and len(CS_TOURNAMENT) >= 16 or
                    purpose.get("game") == "LOL" and len(LOL_TOURNAMENT) >= 16 or
                    purpose.get("game") == "SC2" and len(SC2_TOURNAMENT) >= 16):
                        await sendMessageToDiscord(message, "Unfortunately the maximum number of participants registered for the tournament.")
                        return

                    prompt_msg = "Please, provide the team name." if(purpose.get("game")) in ["DOTA", "CS", "LOL"] else "Please, provide your nickname."
                    STATE[ID] = {"awaiting": "teamName", "game": purpose.get("game")}
                    await sendMessageToDiscord(message, prompt_msg)
                else:
                    await sendMessageToDiscord(message, "Try one more time, specify your game inside your message.")
            elif(purpose.get("purpose") == "list"):
                await handleList(message)
            elif(purpose.get("purpose") == "details"):
                if(purpose.get("game") is not None):
                    await handleDetails(message, purpose.get("game"))
                else:
                    await sendMessageToDiscord(message, "Try one more time, specify your game inside your message.")

client.run(DISCORD_TOKEN)