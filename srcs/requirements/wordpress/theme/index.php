<?php

// ------------------------ LOAD LANDING PAGE ------------------------

if (is_front_page()) {
    readfile(__DIR__ . '/index.html');
    return;
}

readfile(__DIR__ . '/index.html');
