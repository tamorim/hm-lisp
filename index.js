const { Parser } = require('jison')

const grammar = {
}

const parser = new Parser(grammar)
const parserSource = parser.generate()
