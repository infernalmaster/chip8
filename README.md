# chip8 interpreter

## CHIP8 spec:

- http://www.cs.columbia.edu/~sedwards/classes/2016/4840-spring/designs/Chip8.pdf
- http://devernay.free.fr/hacks/chip8/C8TECH10.HTM

## Tutorials:

- https://www.taniarascia.com/writing-an-emulator-in-javascript-chip8/
- https://blog.scottlogic.com/2017/12/13/chip8-emulator-webassembly-rust.html

## Installation

1. Install SFML: https://github.com/oprypin/crsfml#install-sfml
2. run `shards install`

## Development

```
crystal run src/chip8.cr
```

## Create binary

```
shards build
```

Then you can run it

```
bin/chip8
```

and use mouse to pick game and those keys to play:

```
1 2 3 4 
q w e r 
a s d f 
z x c v
```

![Screenshot](/screenshot.png)

## Contributing

1. Fork it (<https://github.com/your-github-user/chip8/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Rostyslav Diachok](https://github.com/infernalmaster) - creator and maintainer
