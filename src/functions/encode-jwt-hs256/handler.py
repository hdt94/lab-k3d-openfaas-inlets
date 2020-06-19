import json
import jwt


def handle(req_str):
    req = json.loads(req_str)
    payload = req.get('payload', {})
    secret = req.get('secret')
    encoded_jwt = jwt.encode(payload, secret, algorithm='HS256').decode('ascii')

    return encoded_jwt