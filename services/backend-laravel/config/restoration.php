<?php

return ['enabled' => filter_var(env('V1007_LOCAL_RESTORATION', false), FILTER_VALIDATE_BOOL), 'port' => (int) env('V1007_DB_PORT', 43317)];
