#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

import common
import re

def FullOTA_Assertions(info):
  AddBasebandAssertion(info)
  return

def IncrementalOTA_Assertions(info):
  AddBasebandAssertion(info)
  return

def AddBasebandAssertion(info):
  android_info = info.input_zip.read("OTA/android-info.txt")
  m = re.search(r'require\s+version-baseband\s*=\s*(\S+)', android_info)
  if m:
    versions = m.group(1).split('|')
    if len(versions) and '*' not in versions:
      cmd = 'assert(oppo.verify_baseband(' + ','.join(['"%s"' % baseband for baseband in versions]) + ') == "1" || abort("ERROR: This package requires firmware from an Android 6 based stock ROM build. Please upgrade firmware and retry!"););'
      info.script.AppendExtra(cmd)
  return
