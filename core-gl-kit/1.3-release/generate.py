#!/usr/bin/python3

from merge.extensions.xproto import XProtoStepGenerator

def add_steps(collector):
	collector.add_step(XProtoStepGenerator())

