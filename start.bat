@echo off
cd /D %~dp0

pwsh -executionpolicy Bypass -command ".\start.ps1"
