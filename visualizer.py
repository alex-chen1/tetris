import pygame
import numpy as np

# This function was used to help design the game board's net and score
# board size and placement. It uses pygame as a display, and I toggle which
# pixels are black or white  using a 640x480 array.
def design():
    pygame.init()
    screen_x = 640
    screen_y = 480
    screen = pygame.display.set_mode((screen_x, screen_y))
    pygame.display.set_caption("Black and White Display")
    
    running = True
    
    # Create a 640x480 array filled with 0 (black)
    pixel_array = np.zeros((screen_y, screen_x), dtype=np.uint8)

    # define size of tetris blocks
    side = 18
    space = 2

    # define size of game board
    rows = 20
    cols = 15

    # draw a board full of blocks
    # define vertical and horizontal start/end points for the game board (not the full display, just the play area)
    vstart = (screen_y - rows * (side + space)) // 2
    hstart = (screen_x - cols * (side + space)) // 2 - 100
    vend = vstart + rows * (side + space)
    hend = hstart + cols * (side + space)
    for i in range(side):
        for col in range(cols):
            pixel_array[vstart + i + space // 2:(vstart + i + (side + space) * rows) + space // 2:(side + space), hstart + col * (side + space) + space // 2:hstart + col * (side + space) + side + space // 2] = 255
    
    # draw the next block tile
    for i in range(side):
        for col in range(4):
            pixel_array[vstart + 120 + i + space // 2:(vstart + 120 + i + (side + space) * 4):(side + space) + space // 2, hend + 50 + col * (side + space) + space // 2:hend + 50 + col * (side + space) + side + space // 2] = 255
    
    # draw "NEXT BLOCK" text
    # draw N
    pixel_array[vstart + 10:vstart + 30, hend + 50:hend + 53] = 255
    for i in range(1,12):
        pixel_array[vstart + 11 + i:vstart + 15 + i, hend + 50 +i] = 255
    pixel_array[vstart + 10:vstart + 30, hend + 62:hend + 65] = 255
    # draw E
    pixel_array[vstart + 10:vstart + 30, hend + 70:hend + 73] = 255
    pixel_array[vstart + 10:vstart + 13, hend + 73:hend + 85] = 255
    pixel_array[vstart + 18:vstart + 21, hend + 73:hend + 85] = 255
    pixel_array[vstart + 27:vstart + 30, hend + 73:hend + 85] = 255
    # draw X
    for i in range(0,15):
        pixel_array[vstart + 11 + i:vstart + 15 + i, hend + 90 + i] = 255
        pixel_array[vstart + 11 + i:vstart + 15 + i, hend + 104 - i] = 255
    pixel_array[vstart + 10:vstart + 15, hend + 90:hend + 95] = 255
    pixel_array[vstart + 25:vstart + 30, hend + 90:hend + 95] = 255
    pixel_array[vstart + 10:vstart + 15, hend + 100:hend + 105] = 255
    pixel_array[vstart + 25:vstart + 30, hend + 100:hend + 105] = 255
    # draw T
    pixel_array[vstart + 10:vstart + 30, hend + 116:hend + 120] = 255
    pixel_array[vstart + 10:vstart + 13, hend + 110:hend + 125] = 255
    # draw B
    pixel_array[vstart + 35:vstart + 55, hend + 40:hend + 43] = 255
    pixel_array[vstart + 35, hend + 40:hend + 53] = 255
    pixel_array[vstart + 36, hend + 40:hend + 54] = 255
    pixel_array[vstart + 37, hend + 40:hend + 55] = 255
    pixel_array[vstart + 43, hend + 40:hend + 54] = 255
    pixel_array[vstart + 44, hend + 40:hend + 55] = 255
    pixel_array[vstart + 45, hend + 40:hend + 54] = 255
    pixel_array[vstart + 52, hend + 40:hend + 55] = 255
    pixel_array[vstart + 53, hend + 40:hend + 54] = 255
    pixel_array[vstart + 54, hend + 40:hend + 53] = 255
    pixel_array[vstart + 38:vstart + 52, hend + 52:hend + 55] = 255
    # draw L
    pixel_array[vstart + 35:vstart + 55, hend + 60:hend + 63] = 255
    pixel_array[vstart + 52:vstart + 55, hend + 60:hend + 75] = 255
    # draw O
    pixel_array[vstart + 35:vstart + 55, hend + 80:hend + 83] = 255
    pixel_array[vstart + 35:vstart + 55, hend + 92:hend + 95] = 255
    pixel_array[vstart + 35:vstart + 38, hend + 80:hend + 95] = 255
    pixel_array[vstart + 52:vstart + 55, hend + 80:hend + 95] = 255
    # draw C
    pixel_array[vstart + 35:vstart + 55, hend + 100:hend + 103] = 255
    pixel_array[vstart + 35:vstart + 38, hend + 100:hend + 115] = 255
    pixel_array[vstart + 52:vstart + 55, hend + 100:hend + 115] = 255
    # draw K
    for i in range(9):
        pixel_array[vstart + 42 + i:vstart + 47 + i, hend + 122 + i] = 255
    for i in range(9):
        pixel_array[vstart + 35 + i:vstart + 40 + i, hend + 130 - i] = 255
    pixel_array[vstart + 35:vstart + 55, hend + 120:hend + 123] = 255

    pixel_array[vstart + 35:vstart + 39, hend + 131] = 255
    pixel_array[vstart + 35:vstart + 38, hend + 132] = 255
    pixel_array[vstart + 35:vstart + 37, hend + 133] = 255

    pixel_array[vstart + 51:vstart + 55, hend + 131] = 255
    pixel_array[vstart + 52:vstart + 55, hend + 132] = 255
    pixel_array[vstart + 53:vstart + 55, hend + 133] = 255

    # draw the number of lines tile
    # draw L
    pixel_array[vstart + 310:vstart + 330, hend + 40:hend + 43] = 255
    pixel_array[vstart + 327:vstart + 330, hend + 40:hend + 55] = 255
    # draw I
    pixel_array[vstart + 310:vstart + 330, hend + 66:hend + 70] = 255
    pixel_array[vstart + 310:vstart + 313, hend + 60:hend + 75] = 255
    pixel_array[vstart + 327:vstart + 330, hend + 60:hend + 75] = 255
    # draw N
    pixel_array[vstart + 310:vstart + 330, hend + 80:hend + 83] = 255
    for i in range(1,12):
        pixel_array[vstart + 311 + i:vstart + 315 + i, hend + 80 + i] = 255
    pixel_array[vstart + 310:vstart + 330, hend + 92:hend + 95] = 255
    # draw E
    pixel_array[vstart + 310:vstart + 330, hend + 100:hend + 103] = 255
    pixel_array[vstart + 310:vstart + 313, hend + 103:hend + 115] = 255
    pixel_array[vstart + 318:vstart + 321, hend + 103:hend + 115] = 255
    pixel_array[vstart + 327:vstart + 330, hend + 103:hend + 115] = 255
    # draw S
    pixel_array[vstart + 310:vstart + 321, hend + 120:hend + 123] = 255
    pixel_array[vstart + 310:vstart + 313, hend + 123:hend + 135] = 255
    pixel_array[vstart + 318:vstart + 321, hend + 123:hend + 135] = 255
    pixel_array[vstart + 327:vstart + 330, hend + 120:hend + 135] = 255
    pixel_array[vstart + 318:vstart + 330, hend + 132:hend + 135] = 255

    # draw score
    # hundreds digit
    pixel_array[vstart + 360:vstart + 363, hend + 63:hend + 72] = 255
    pixel_array[vstart + 363:vstart + 369, hend + 72:hend + 75] = 255
    pixel_array[vstart + 372:vstart + 378, hend + 72:hend + 75] = 255
    pixel_array[vstart + 378:vstart + 381, hend + 63:hend + 72] = 255
    pixel_array[vstart + 372:vstart + 378, hend + 60:hend + 63] = 255
    pixel_array[vstart + 363:vstart + 369, hend + 60:hend + 63] = 255
    pixel_array[vstart + 369:vstart + 372, hend + 63:hend + 72] = 255

    # tens digit
    pixel_array[vstart + 360:vstart + 363, hend + 83:hend + 92] = 255
    pixel_array[vstart + 363:vstart + 369, hend + 92:hend + 95] = 255
    pixel_array[vstart + 372:vstart + 378, hend + 92:hend + 95] = 255
    pixel_array[vstart + 378:vstart + 381, hend + 83:hend + 92] = 255
    pixel_array[vstart + 372:vstart + 378, hend + 80:hend + 83] = 255
    pixel_array[vstart + 363:vstart + 369, hend + 80:hend + 83] = 255
    pixel_array[vstart + 369:vstart + 372, hend + 83:hend + 92] = 255

    # ones digit
    pixel_array[vstart + 360:vstart + 363, hend + 103:hend + 112] = 255
    pixel_array[vstart + 363:vstart + 369, hend + 112:hend + 115] = 255
    pixel_array[vstart + 372:vstart + 378, hend + 112:hend + 115] = 255
    pixel_array[vstart + 378:vstart + 381, hend + 103:hend + 112] = 255
    pixel_array[vstart + 372:vstart + 378, hend + 100:hend + 103] = 255
    pixel_array[vstart + 363:vstart + 369, hend + 100:hend + 103] = 255
    pixel_array[vstart + 369:vstart + 372, hend + 103:hend + 112] = 255
    
    # draw frames
    pixel_array[vstart - side - space - 5:vstart - side - space, hstart - side - space - 5:hend + 160] = 255
    pixel_array[vend + side + space:vend + side + space + 5, hstart - side - space - 5:hend + 160] = 255
    pixel_array[vstart - side - space - 5:vend + side + space, hstart - side - space - 5:hstart - side - space] = 255
    pixel_array[vstart - side - space - 5:vend + side + space, hend + side + space:hend + side + space + 5] = 255
    pixel_array[vstart - side - space - 5:vend + side + space + 5, hend + 160:hend + 165] = 255
    pixel_array[vstart + 260:vstart + 265, hend + side + space:hend + 165] = 255

    pixel_array[vstart - 6:vstart - 1, hstart - 6:hend + 6] = 255
    pixel_array[vend + 1:vend + 6, hstart - 6:hend + 6] = 255
    pixel_array[vstart - 1:vend + 1, hstart - 6:hstart - 1] = 255
    pixel_array[vstart - 1:vend + 1, hend + 1:hend + 6] = 255

    pixel_array = pixel_array.T
    
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
        
        # Convert array to a Pygame surface
        surface = pygame.surfarray.make_surface(np.stack([pixel_array]*3, axis=-1))
        screen.blit(surface, (0, 0))
        pygame.display.flip()
    
    pygame.quit()

def testbench():

    # open output file generated by the VHDL simulation
    with open("[insert filename]", 'r') as f:
        results = f.readlines()
        results = [s.rstrip() for s in results]

    # for every line in the output file, display the corresponding image
    for i in range(len(results)):
        pygame.init()
        screen = pygame.display.set_mode((640, 480))
        pygame.display.set_caption(f"Test Case {i+1}")

        # parse the results from a string into a 480 x 640 array
        pixel_array = np.array(list(results[i].replace('U', '1')), dtype=int).reshape(480, 640)
        # multiply by 255 so high bits on the output are white
        pixel_array = pixel_array * 255
        # flip the array so it displays correctly
        pixel_array = pixel_array.T
        
        running = True
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
            
            # Convert array to a Pygame surface
            surface = pygame.surfarray.make_surface(np.stack([pixel_array]*3, axis=-1))
            screen.blit(surface, (0, 0))
            pygame.display.flip()
        
        pygame.quit()

if __name__ == "__main__":
    design()