#!/usr/bin/env python3
"""Export mobile loops from the firmware's canonical frames; no AI generation.
Run after firmware/tools/generate_pet_scene.py from an initialized superproject.
"""
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[2]
source = root / 'firmware/assets/generated'
target = root / 'mobile/assets/images'
sheet = Image.open(source / 'pet_frames.png').convert('RGBA')
background = Image.open(source / 'room_background.png').convert('RGBA')
for row, emotion in enumerate(('idle', 'happy', 'curious', 'sleep')):
    views = []
    pets = []
    for frame in range(32):
        pet = sheet.crop((frame * 96, row * 72, (frame + 1) * 96, (row + 1) * 72))
        pets.append(pet)
        scene = background.copy()
        scene.alpha_composite(pet, (112, 72))
        views.append(scene.convert('RGB'))
    views[0].save(target / f'xuna_{emotion}.png')
    views[0].save(target / f'xuna_{emotion}.gif', save_all=True,
                  append_images=views[1:], duration=100, loop=0, disposal=2)

    pets[0].save(target / f'xuna_pet_{emotion}.png')

    pets[0].save(target / f'xuna_pet_{emotion}.gif', save_all=True,
                 append_images=pets[1:], duration=100, loop=0, disposal=2)
