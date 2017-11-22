
def main():
    with open('sound.txt', 'w') as result:
        with open('sound.h', 'r') as f:
            for line in f.readlines():
                result.write('{0:08b}\n'.format(int(line)))
    return

if __name__ == '__main__':
    main()