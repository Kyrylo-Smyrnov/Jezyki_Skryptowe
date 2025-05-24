local consts = {}

consts.WINDOW_WIDTH = 800
consts.WINDOW_HEIGHT = 800

consts.FIELD_WIDHT = 10
consts.FIELD_HEIGHT = 20
consts.FIELD_BACKGROUND_COLOR = {0.3, 0.3, 0.3}
consts.SCORE_COLOR = {0.9, 0.9, 0.9}

consts.BLOCK_SIZE = 30
consts.FALL_RATE = 0.5

consts.BLOCK_START_POINT = {x = consts.WINDOW_WIDTH / 2,
                            y = consts.WINDOW_HEIGHT / 2 - consts.FIELD_HEIGHT / 2 * consts.BLOCK_SIZE}
consts.FIELD_START_POINT = {x = consts.WINDOW_WIDTH / 2 - consts.FIELD_WIDHT / 2 * consts.BLOCK_SIZE,
                            y = consts.WINDOW_HEIGHT / 2 - consts.FIELD_HEIGHT / 2 * consts.BLOCK_SIZE}

return consts