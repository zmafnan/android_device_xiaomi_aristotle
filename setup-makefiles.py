#!/usr/bin/env -S PYTHONPATH=../../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

import importlib.util
from pathlib import Path


script = Path(__file__).with_name("extract-files.py")
spec = importlib.util.spec_from_file_location("aristotle_extract", script)
assert spec is not None and spec.loader is not None
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

module.ExtractUtils.device(module.module).run()
