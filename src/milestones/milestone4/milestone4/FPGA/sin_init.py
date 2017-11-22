
import math

def main():
    values = []
    for i in range(256):
        rad = 2.0 * math.pi * i / 256
        val = int(math.sin(rad) * 127) + 127
        values.append(val)
    with open('sin_init.txt', 'w') as f:
        for val in values:
            f.write('{0:08b}\n'.format(val))
    return

if __name__ == '__main__':
    main()