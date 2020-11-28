@echo off
cd /D %~dp0

:: NOTE: ALL WORKERS AND SMART LIFE DEVICES SHOULD BE NAMED THE SAME

pwsh -executionpolicy Bypass -command ".\start.ps1"
