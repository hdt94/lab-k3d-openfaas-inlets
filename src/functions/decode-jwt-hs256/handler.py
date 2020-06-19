import json
import jwt


def handle(req_str):
    req = json.loads(req_str)
    encoded = req.get('encoded', {})
    secret = req.get('secret')
    decoded = jwt.decode(encoded, secret, algorithms='HS256')

    return decoded