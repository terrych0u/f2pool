#!/usr/bin/env python3

import os
import signal
import sys
import requests
import time
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import desc
from ipaddress import IPv4Address, AddressValueError

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get("DATABASE_URL")
db = SQLAlchemy(app)


class QueryLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    query_type = db.Column(db.String(20))
    query = db.Column(db.String(120))
    result = db.Column(db.String(120))
    timestamp = db.Column(db.Integer)


@app.route('/')
def index():
    return jsonify({
        "version": "0.1.0",
        "date": int(time.time()),
        "kubernetes": 'KUBERNETES_SERVICE_HOST' in os.environ
    })


@app.route("/v1/tools/lookup")
def lookup():
    domain = request.args.get("domain")
    try:
        ip = IPv4Address(requests.get(
            f"https://api.hackertarget.com/hostsearch/?q={domain}").text.split(",")[0])
        query = Query(query=domain, result=str(ip))
        db.session.add(query)
        db.session.commit()
        return str(ip)
    except (AddressValueError, IndexError):
        return "Invalid domain", 400


@app.route('/v1/tools/validate')
def validate():
    ip_address = request.args.get('ip')
    try:
        socket.inet_aton(ip_address)
        is_valid = True
    except socket.error:
        is_valid = False
    query_log = QueryLog(query_type='validate', query=ip_address,
                         result=is_valid, timestamp=int(time.time()))
    db.session.add(query_log)
    db.session.commit()
    return jsonify({"is_valid": is_valid})


@app.route("/v1/history")
def history():
    queries = Query.query.order_by(desc(Query.id)).limit(20).all()
    return jsonify([{"query": query.query, "result": query.result} for query in queries])


@app.route('/health')
def health():
    return jsonify({"status": "ok"})


@app.route('/metrics')
def metrics():
    # TODO: Implement Prometheus metrics endpoint
    pass


def shutdown(signum, frame):
    print('Shutting down...')
    time.sleep(1)
    sys.exit(0)


signal.signal(signal.SIGTERM, shutdown)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=3000)
