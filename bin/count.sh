#!/bin/sh

find . -name "*.dart" | xargs cat | wc -c
