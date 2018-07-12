import sys
import json
import ast
import argparse

_encoders = {
    None: lambda x: str(x),
    'json': lambda x: json.dumps(x),
    'escape': lambda x: json.dumps(str(x))[1:-1],
    'literal': lambda x: repr(x)
}
_decoders = {
    None: lambda x: x,
    'json': lambda x: json.loads(x),
    'escape': lambda x: json.loads('"' + x + '"'),
    'literal': lambda x: ast.literal_eval(x)
}



def emit(key, value=None, key_encoder='literal', value_encoder='literal'):
    key_encoder = _encoders.get(key_encoder, key_encoder)
    value_encoder = _encoders.get(value_encoder, value_encoder)

    if value is None:
        print(key_encoder(key))
    else:
        print('%s\t%s' % (key_encoder(key), value_encoder(value)))


def read_tuples(key_decoder='literal', value_decoder='literal', group_by_key=False):
    data = _raw_input_tuples(key_decoder=key_decoder, value_decoder=value_decoder)
    if group_by_key:
        data = _group_tuples(data)
    for x in data:
        yield x


def main(**actions):
    parser = argparse.ArgumentParser(description='Map-Reduce Jobs with Hadoop Streaming')
    parser.add_argument('job', metavar='JOB', help='Which job to execute [%s]' % (', '.join(actions.keys())), choices=actions.keys())
    parser.add_argument('action', metavar='ACTION', help='Which action to execute [map, reduce, combine]', choices=['map', 'reduce', 'combine'])
    args = parser.parse_args()
    getattr(actions[args.job], args.action)()


def _raw_input_tuples(key_decoder=None, value_decoder=None):
    key_decoder = _decoders.get(key_decoder, key_decoder)
    value_decoder = _decoders.get(value_decoder, value_decoder)

    for line in sys.stdin:
        record = line.strip().split("\t", 1)
        if len(record) == 2:
            yield key_decoder(record[0]), value_decoder(record[1])
        else:
            yield key_decoder(record[0]), None


def _group_tuples(tuples):
    current_it = None
    next_entry = None

    def first_values():
        nonlocal next_entry
        if False:
            yield None
        next_entry = next(tuples, None)

    def main_values(first_entry):
        nonlocal next_entry
        yield first_entry[1]

        for entry in tuples:
            if entry[0] == first_entry[0]:
                yield entry[1]
            else:
                next_entry = entry
                return
        next_entry = None

    def exaust(it):
        for x in it:
            pass

    current_it = first_values()

    while True:
        exaust(current_it)
        if next_entry is None:
            break

        key = next_entry[0]
        current_it = main_values(next_entry)
        yield key, current_it
