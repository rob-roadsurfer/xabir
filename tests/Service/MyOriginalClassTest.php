<?php


namespace App\Tests\Service;


use App\Service\MyOriginalClass;
use Monolog\Test\TestCase;

class MyOriginalClassTest extends TestCase
{
    public function testReturnsZero()
    {
        $class = new MyOriginalClass();
        $this->assertEquals(0, $class->returnZero());
    }
}
