<?php

namespace App\Domain\Matching;

enum OperationAction: string
{
    case Schedule = 'schedule';
    case Execute = 'execute';
    case Cancel = 'cancel';
    case Retry = 'retry';
    case Reveal = 'reveal';
    case Close = 'close';
    case Compensate = 'compensate';
}
